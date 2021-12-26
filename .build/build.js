#!node -r shelljs-wrap

function jsMacroEngine(file, ctx, args){
  /*
  Very simple JS macros system. Runs everything between “--[[?” and “?]]” through JS. Function “out(…)” is available for outputting things. Also,
  value returned by that bit of code would also be included. Inside the macro, “out(]] … --[[)” can be used to output a bit of native Lua code.
  And inside that native code it’s possible to refer to macro variables by adding __ in the front and to the back of them. Examples:

  --[[? out('hello world'); ?]]
  local builtAt = --[[? return JSON.stringify('Built at ' + new Date()) ?]]
  local builtAt = "--[[? return 'Built at ' + new Date() ?]]"  -- gotta be careful with quotes here, but this one is more Lua parser friendly

  And example with inverse comments:

  --[[? for (let i = 0; i < 10; ++i) out(]] local item__i__ = __i__ --[[) ?]]

  This would produce:
  local item0 = 0
  local item1 = 1
  local item2 = 2
  etc.

  Note: to get Lua code as a string inside macro, you don’t need to use out, important part is inverse comment in round brackets:

  --[[? let i = 0; let luaCode = (]] function fn__i__() return __i__ end --[[); out(luaCode); ?]]

  Other files can be included with `inc(filename)` function. Macros all have shared namespace which can be accessed via `ctx`. So included files
  can define new functions there too. When including, other arguments can be passed to included function as an array: `inc('filename.tpl.lua', 0, 1)`
  would mean that `filename.tpl.lua` would have a value `args[0]` set to 0 and args[1] set to 1. Included file would get preprocessed the same and 
  resulting Lua code would be returned from `inc()` call.
  */
  return ('' + file).replace(/--\[\[\?([\s\S]+?)\?\]\]/g, (_, m) => {
    const r = [], f = new Function('out,ctx,inc,args', m.replace(/\(\]\]([\s\S]+?)--\[\[\)/g, (_, b) => `(${JSON.stringify(b).replace(/__(\w+)__/g, (_, k) => `"+${k}+"`)})`));
    return r.push(f(r.push.bind(r), ctx, (f, ...a) => jsMacroEngine(fs.readFileSync(f), ctx, a), args || [])), r.join('');
  });
}


// Options:
const minifyFfiDefinitions = true;

// Data:
const enumTypes = {};
const luaTypes = {};
const knownTypes = {
  regex: /^(void|char|ray|lua_string_ref|lua_string_cached_ref|int|u?int\d+_t|size_t|float|double|bool|vec[234]|mat3x3|mat4x4|rgbm?|refbool|refnumber)$/,
  ffiStructs: {},
  referencedTypes: {},
  ffiFunctions: {},
  referencedFunctions: {}
}
const knownLDocTypes = {};

let commonDeclarations = '';

// Checking types to detect errors early:
function resetTypes() {
  knownTypes.ffiStructs = {};
  knownTypes.referencedTypes = {};
  knownTypes.ffiFunctions = {};
  knownTypes.referencedFunctions = {};
}

function checkTypes() {
  function knownType(luaType) {
    if (knownTypes.regex.test(luaType)) return true;
    if (knownTypes.ffiStructs.hasOwnProperty(luaType)) return true;
    return false;
  }

  function knownFunction(luaFunction) {
    if (knownTypes.ffiFunctions.hasOwnProperty(luaFunction)) return true;
    return false;
  }

  for (let k in knownTypes.referencedTypes) {
    if (!knownType(k)) {
      $.echo(β.yellow(`Possibly unknown type: ${k} (cpp: ${knownTypes.referencedTypes[k]})`))
    }
  }

  for (let k in knownTypes.referencedFunctions) {
    if (!knownFunction(k)) {
      $.echo(β.yellow(`Possibly unknown function: ${k}`))
    }
  }
}

// Rules:
function notForExport(t) {
  if (/^(lj_memmove|lj_malloc|lj_calloc|lj_realloc|lj_free)$/.test(t)) return true;
  if (/lj_[^_]+_[^_]/.test(t)) return true;
  return false;
}

function requireToIgnore(callRequire) {
  return callRequire == 'ffi' || /^table\.\w+$/.test(callRequire);
}

function baseTypeToLua(t) {
  if (/^float(\d)$/.test(t)) return `vec${RegExp.$1}`;
  if (/^float(\dx\d)$/.test(t)) return `mat${RegExp.$1}`;
  if (t === 'uint') return 'uint32_t';
  if (t === 'size_t') return 'uint64_t';
  if (enumTypes.hasOwnProperty(t)) return enumTypes[t].underlying || 'int';
  if (luaTypes.hasOwnProperty(t)) return luaTypes[t];
  if (/_array$/.test(t)) return 'void';
  return t;
}

function typeToLua(t, origin) {
  // if (knownLDocTypes[t]) return knownLDocTypes[t];

  let m = 0;
  t = t.replace(/^(const\s*)?([\w:]+)([&*])?$/, (_, p, v, x) => {
    ++m;
    const y = baseTypeToLua(v);
    knownTypes.referencedTypes[y] = _ + '; origin: ' + origin;
    return (p || '') + y + (x || '');
  });
  if (m !== 1) {
    $.fail(`unexpected type: “${t}”`);
  }
  return t;
}

function crunchC(code) {
  code.replace(/\}\s+(\w+)\b/g, (_, n) => knownTypes.ffiStructs[n] = true);
  code.replace(/\b(lj_\w+)\b/g, (_, n) => knownTypes.ffiFunctions[n] = true);
  return code.replace(/--.+/g, '').replace(/\s([\w:]+)\s+(\w+);/g, (_, n, v) => {
    const l = typeToLua(n, _);
    if (l !== n) {
      return ` ${l} ${v};`
    }
    if (/:/.test(n)) {
      $.fail(`unknown type: “${n}”`);
    }
    return _;
  }).replace(/(?<!:)\/\/(?!@).+/g, '').trim().replace(/\t+/g, '').replace(/([{;,*&])\s+/g, '$1').replace(/ ([{])/g, '$1');
}

function defaultValueToLua(t) {
  if (!t) return null;
  return t.replace(/[{}]/g, _ => _ == '{' ? '(' : ')').replace(/\d\.?f\b/g, _ => _[0]);
}

const isVectorType = (() => {
  function createType(type) {
    function poolName(arg, localDefines) {
      const typeIndex = `__tmp_${type}${arg.allArgs.filter(x => x.typeInfo.name == arg.typeInfo.name && x.index < arg.index).length}`;
      if (!localDefines[typeIndex]) localDefines[typeIndex] = { key: typeIndex, value: `${type}()` };
      return typeIndex;
    }

    return {
      createNew: (arg, localDefines, defaultValue) => defaultValue == 'nullptr' 
        ? `__ut${type}(${poolName(arg, localDefines)}, ${arg.name}, nil)` 
        : `__ut${type}(${poolName(arg, localDefines)}, ${arg.name}, ${defaultValue})`
    };
  }

  const vectorTypes = {
    vec2: createType('vec2'),
    vec3: createType('vec3'),
    vec4: createType('vec4'),
    rgb: createType('rgb'),
    rgbm: createType('rgbm'),
    mat3x3: createType('mat3x3'),
    mat4x4: createType('mat4x4'),
  };

  return type => vectorTypes[type];
})();

function isRefType(type) {
  return type === 'refbool' || type === 'refnumber';
}

function getTypeInfo(type, customTypes) {
  if (type === 'const char*') {
    return {
      name: 'string',
      default: '""',
      prepare: arg => `tostring(${arg.name})`,
      forceExpression: true
    };
  }

  if (type === 'const lua_string_ref*' || type === 'const lua_string_cached_ref*') {
    return {
      name: 'string',
      default: '""',
      prepare: arg => `tostring(${arg.name})`,
      forceExpression: true
    };
  }

  if (type === 'int' || type === 'uint' || type == 'int64_t' || type == 'uint64_t' || type == 'int32_t' || type == 'uint32_t') {
    return {
      name: 'integer',
      default: null,
      prepare: arg => `tonumber(${arg.name}) or ${arg.default || 0}`,
      forceExpression: true
    };
  }

  if (type === 'float' || type === 'double') {
    return {
      name: 'number',
      default: null,
      prepare: arg => `tonumber(${arg.name}) or ${arg.default || 0}`,
      forceExpression: true
    };
  }

  if (type === 'bool') {
    return {
      name: 'boolean',
      default: null,
      prepare: arg => arg.default == 'true' ? `(${arg.name} or ${arg.name} == nil) and true or false` : `${arg.name} and true or false`,
      forceExpression: true
    };
  }

  const enumType = enumTypes[type];
  if (enumType != null) {
    return {
      name: enumType.name,
      default: null,
      prepare: enumType.passThrough
        ? arg => `tonumber(${arg.name}) or ${enumType.default}`
        : arg => `__uce(${arg.name}, ${enumType.min}, ${enumType.max}, ${arg.default != null ? enumType.resolveValue(arg.default) : enumType.default})`,
      prepareHandlesDefault: !enumType.passThrough
    };
  }

  const luaType = typeToLua(/([\w:]+)[*&]?$/.test(type) ? RegExp.$1 : type);
  const vectorType = isVectorType(luaType);
  if (vectorType != null) {
    return {
      name: luaType,
      default: `${luaType}()`,
      prepare: (arg, localDefines, defaultValue) => vectorType.createNew(arg, localDefines, defaultValue),
      forceExpression: true,
      prepareHandlesDefault: true
    };
  }

  if (isRefType(luaType)) {
    return {
      name: luaType,
      default: `${luaType}()`,
      prepare: (arg, localDefines, defaultValue) => `__util.secure_${luaType}(${arg.name}, ${defaultValue})`,
      forceExpression: true,
      prepareHandlesDefault: true
    };
  }

  const valueRequired = !/\*$/.test(type);
  const customType = customTypes[luaType];
  if (customType != null) {
    return {
      name: customType,
      default: valueRequired ? null : 'nil',
      prepare: arg => valueRequired
        ? `if ffi.istype('${luaType}', ${arg.name}) == false then 
          if ${arg.name} == nil then error("Required argument '${arg.niceName}' is missing", 2) end 
          error("Argument '${arg.niceName}' requires a value of type ${customType}", 2) 
        end`
        : `if ffi.istype('${luaType}', ${arg.name}) == false then 
          error("Argument '${arg.niceName}' requires a value of type ${customType}", 2) 
        end`
    };
  }

  return {
    name: /^state_/.test(luaType) ? 'ac.' + toDocName(luaType, customTypes) : toDocName(luaType, customTypes),
    default: valueRequired ? null : 'nil',
    prepare: arg => {
      // if (valueRequired){
      //   return `if ffi.istype('${luaType}', ${arg.name}) == false then 
      //     if ${arg.name} == nil then error("Required argument '${arg.niceName}' is missing", 2) end 
      //     error("Argument '${arg.niceName}' requires a value of type ${customType}", 2) 
      //   end`
      // }
      $.echo(β.red(`Prepare function is missing for ${type} (Lua type: ${luaType})`)); return '' 
    }
  };
}

function toDocName(luaType, customTypes) {
  if (luaType === 'uint64_t') return 'uint64';

  if (luaType === 'lua_vector_int') return 'integer[]';

  const knownType = /^state_/.test(luaType);
  if (!knownType) {
    // $.echo(`Unknown type: ${luaType}`);
    // return '<' + luaType + '>';
    return luaType;
  }

  return knownType ? toNiceName(luaType, true) : '?';
}

function isStatementPrepare(x) {
  return / = |\n/.test(x);
}

function prepareParam(arg, wrapDefault, localDefines) {
  if (arg.default != null) {
    if (arg.typeInfo.name === 'boolean') {
      return arg.default === 'false' ? `${arg.name} and true or false` : `${arg.name} ~= false`;
    }

    if (arg.typeInfo.name === 'number') {
      return `tonumber(${arg.name}) or ${arg.default}`;
    }

    if (arg.typeInfo.name === 'string' && arg.default === 'nullptr') {
      return `__uso(${arg.name})`;
    }
  } else if (arg.typeInfo.name === 'string') {
    return `__ust(${arg.name})`;
  }

  if (arg.typeInfo.default == null && arg.default == null) {
    return arg.typeInfo.prepare(arg, localDefines);
  }

  let defaultWrapped = wrapDefault(arg.default || arg.typeInfo.default);
  let localPrepare = arg.typeInfo.prepare(arg, localDefines, defaultWrapped);

  if (arg.typeInfo.prepareHandlesDefault) {
    return localPrepare;
  }

  if (!isStatementPrepare(localPrepare)) {
    if (arg.typeInfo.forceExpression) {
      return `${arg.name} ~= nil and (${localPrepare}) or (${defaultWrapped})`;
    }

    localPrepare = `${arg.name} = ${localPrepare}`;
  }

  return `if ${arg.name} ~= nil then 
    ${localPrepare} 
  else
    ${arg.name} = ${defaultWrapped} 
  end`;
}

function toNiceName(name, typeName) {
  return (typeName ? name.replace(/(?:_|^)([a-z])/g, (_, a) => a.toUpperCase()) : name.replace(/_([a-z])/g, (_, a) => a.toUpperCase()))
    .replace(/(?<=[a-z])Id(?=[A-Z]|$)/g, _ => _.toUpperCase());
}

function wrapParamDefinition(arg) {
  if (arg.typeInfo.name === '?') $.echo(β.yellow(`Unknown Lua type: ${arg.type}`));
  return arg.default ? `${arg.niceName}: ${arg.typeInfo.name} = ${arg.default}` : `${arg.niceName}: ${arg.typeInfo.name}`;
}

function convertLDocDefaultValue(value){
  if (!Number.isNaN(+value)) return value;
  if (value == 'vec2()') return '`vec2(0, 0)`';
  if (value == 'vec3()') return '`vec3(0, 0, 0)`';
  if (value == 'vec4()') return '`vec3(0, 0, 0, 0)`';
  if (value == 'rgbm(1, 1, 1, 1)') return '`rgbm.colors.white`';
  if (value == 'rgbm(0, 0, 0, 1)') return '`rgbm.colors.black`';
  if (value == 'rgbm(0, 0, 0, 0)') return '`rgbm.colors.transparent`';
  if (value == 'nullptr') return '`nil`';
  if (/^"(.*)"$/.test(value)) return `'${RegExp.$1}'`;
  return `\`${value}\``;
}

const enumOverrides = [];

function findLDocType(arg, enumDefs, namespace, fnName){
  let type = arg.typeInfo.name;
  for (let d of enumOverrides){
    if (d.params.override && d.params.override.test(`${namespace}.${fnName}/${arg.niceName}:${type}`)){
      type = d.params.name;
      break;
    }
  }
  return type;
}

function wrapParamLDoc(arg, enumDefs, namespace, fnName) {
  if (arg.typeInfo.name === '?') $.echo(β.yellow(`Unknown LDoc type: ${arg.type}`));
  let comment = '';
  let type = arg.typeInfo.name;

  if (arg.comment && /^(.*)\b(fun\(.+)/.test(arg.comment)){
    type = RegExp.$2.trim();
    arg.comment = RegExp.$1.trim();
  }

  if (arg.comment) { 
    comment = `${comment} ${arg.comment.replace(/^@/, '').trim().replace(/^[a-z]/, _ => _.toUpperCase())}`; 
    if (!/[.?!]$/.test(comment)) comment += '.';
  }

  let defaultValue = arg.default;
  for (let d of enumOverrides){
    if (d.params.override && d.params.override.test(`${namespace}.${fnName}/${arg.niceName}:${type}`)){
      type = d.params.name;
      if (defaultValue){
        const ndv = Object.entries(d.values).filter(x => (!d.comments[x[0]] || !/@hidden/.test(d.comments[x[0]])) && '' + x[1] == '' + defaultValue)[0][0];
        if (!ndv) $.fail(`default value is not found in enum: ${defaultValue} (${d.params.name})`);
        defaultValue = d.params.name + '.' + ndv;
      }
      break;
    }
  }

  if (defaultValue) comment = `${comment} Default value: ${convertLDocDefaultValue(defaultValue)}.`;
  if (comment) comment = ' @' + comment.trim();
  if (defaultValue && defaultValue != 'nullptr') comment = '?' + comment;

  return `---@param ${arg.niceName} ${type}${defaultValue == 'nullptr' ? '|nil' : ''}${comment}`;
}

function wrapReturnDefinition(arg, customTypes) {
  if (arg === 'void') return '';
  return `: ${getTypeInfo(arg, customTypes).name}`;
}

function getLDocType(arg, customTypes) {
  let type = getTypeInfo(arg, customTypes).name;
  if (type == 'uint64') return 'integer';
  return type;
}

function wrapLDocSentence(v) {
  v = v.replace(/^ (?<!:)\/\/ /, '').replace(/^[a-z]/, _ => _.toUpperCase());
  if (!/^\s*\!\[|[.!?]|```$/.test(v)) v = v + '.';
  return v;
}

function wrapReturnLDoc(arg, customTypes, docs, comment) {
  if (arg === 'void') return null;
  if (docs && comment) return `---@return ${getLDocType(arg, customTypes)} @${wrapLDocSentence(comment)}`;
  return `---@return ${getLDocType(arg, customTypes)}`;
}

function wrapReturnLComment(docs, comment) {
  if (!docs && !comment) return null;

  if (docs) {
    comment = docs.replace(/\s+\*/g, '\n').replace(/\n\n\n/g, '\n\n').trim();
  }

  let d = [];
  comment = wrapLDocSentence(comment.replace(/\n@.+/g, _ => (d.push(_), '')).trim());
  if (d.length > 0) comment += d.join('');

  return `---${comment.replace(/\n/g, '\n---')}`;
}

function needsWrappedResult(type) {
  if (/const (?:char|lua_string_ref|lua_string_cached_ref)\*/.test(type)) return true;
  return false;
}

function wrapResult(type) {
  if (type == 'void') return { callback: x => x, extraData: null };
  if (/state_/.test(type)) return { callback: x => `return __uss(${x})`, extraData: null };
  if (/const char\*/.test(type)) return { callback: x => `return ffi.string(${x})`, extraData: null };
  if (/const lua_string_ref\*/.test(type)) return { callback: x => `return __usf(${x})`, extraData: null };
  if (/const lua_string_cached_ref\*/.test(type)) return { callback: (x, y) => `return __${y}_c:get(${x})`, extraData: y => `local __${y}_c = __ucf()` };
  return { callback: x => `return ${x}`, extraData: null };
}

function extendArg(arg, fnName, allArgs, customTypes) {
  arg.niceName = toNiceName(arg.name);
  arg.typeInfo = getTypeInfo(arg.type, customTypes);
  arg.allArgs = allArgs;
}

// Actual processing
const parser = require('./utils/luaparse');
const luamax = require('./utils/luamax');

const defBr = { '[': ']', '{': '}', '(': ')', '<': '>' };
const baseBr = { '(': ')' };
const cspSource = `${process.env['CSP_ROOT']}/source`;

function brackets(s, reg, br, cb) {
  for (var i, r = '', m, o, f, b = br || defBr; m = reg.exec(s); s = s.substr(i + 1)) {
    r += s.substr(0, m.index);
    for (i = m.index + m[0].length, o = []; i < s.length; i++) {
      if (b.hasOwnProperty(s[i])) { if (!o.length) f = i; o.push(b[s[i]]); continue; }
      else if (s[i] == o[0] && (o.shift(), !o.length)) r += cb(m, s.substring(f + 1, i));
      else if (o.length == 0 && s[i] != ' ' && s[i] != '\t' && s[i] != '\n' && s[i] != '\r') {
        r += cb(m, '');
        i = m.index + m[0].length - 1;
      }
      else continue;
      break;
    }
  }
  return r + s;
}

function split(s, sep, br) {
  for (var r = [], o = [], l = 0, b = br || defBr, i = 0; i < s.length; i++) {
    if (b.hasOwnProperty(s[i])) o.push(b[s[i]]);
    else if (s[i] == o[0]) o.shift();
    else if (o.length == 0 && s[i] == sep) { r.push(s.substring(l, i)); l = i + 1; }
  }
  return r.concat(s.substring(l));
}

const processMacros = (src => {
  // list of macroses:
  let ms = [];

  // parse all defines into a neat list of functions
  $.readText(src).replace(
    /\n#define (\w+)\(((?:\w+|\.\.\.)(?:,\s*(?:\w+|\.\.\.))*)\)\s*((.+|(?!\n#define)[\s\S])+)/g,
    (_, n, a, b) => {
      if (n == 'LUATYPEDEF') return;
      const args = a.split(',').map(x => x.trim().replace('...', '')).map(x => [
        eval('/(##?|\\b)' + (x || '__VA_ARGS__') + '(##|\\b)/g'),
        i => ((r, v) => v[0] == '#' && v[1] != '#' ? JSON.stringify(r) : r).bind(0, x ? i.shift() : i.join(', '))
      ]).map(a => (x, i) => x.replace(a[0], a[1](i)));
      ms.push(s => brackets(s, eval('/\\b' + n + '\\b/'), baseBr,
        (_, a) => args.reduce(((i, a, b) => b(a, i)).bind(0, split(a, ',').map(x => x.trim())), b.replace(/\\\n/g, '\n'))));
    });

  // flipping list
  ms = ms.concat(x => x.replace(/(?<!:)\/\/(?!@).+/g, '').replace(/\n\s*(?=\n)/g, '')).reverse();

  // returning function reading file and returning it processed
  return x => ms.reduce((a, b) => b(a), x);
})(`${cspSource}/lua/api_macro.h`);

const stateDefinitionsUpdated = {};
const verified = {};

function verifyCppFile(cpp, cppName){
  if (verified[cppName]) return cpp;
  verified[cppName] = true;

  if (cppName != 'extensions/weather_fx/ac_ext_weather_fx__lua.h') {
    const ends = {};
    cpp.replace(/\bLUAEXPORT\b([^(]+)\(/g, (_, n) => {
      const k = /__(\w+)/.test(n) ? RegExp.$1 : '<none>';
      (ends[k] || (ends[k] = [])).push(/(\w+)$/.test(n) ? RegExp.$1 : _);
    });
    if (Object.keys(ends).length > 1){
      $.echo(β.red(`\t${cppName}: too many postfixes: ${Object.keys(ends).join(', ')}${Object.entries(ends).map(x => `\n\t\t${x[0]}: ${x[1].slice(0, 3).join(', ')}${x[1].length > 3 ? ', …' : ''}`)}`));
    }
  }

  const verifyFilename = `.verify/${path.basename(cppName, '.cpp')}.h`;
  if (fs.existsSync(verifyFilename)){
    const l = $.readText(verifyFilename).split('\n').map(x => x.trim()).filter(x => /\w\(/.test(x));
    const f = l.filter(x => /(\w+)\(/.test(x) ? cpp.indexOf(RegExp.$1) !== -1 : false);
    if (f.length != l.length) {
      $.echo(β.yellow(`\tAPI verification: ${f.length} out of ${l.length} are added`));
      fs.writeFileSync(`${verifyFilename}.out`, l.filter(x => !f.includes(x)).join('\n'))
    }
  }

  return cpp;
}

function getLuaCode(opts, definitionsCallback) {
  const ffiDefinitions = [];
  const ffiStructures = [];
  const localDefines = {};
  const exportEntries = [];
  const docDefinitions = [];
  const docDeclarations = ['\n--[[ csp.lua ]]\n'];

  const data = opts.sources.map(x => verifyCppFile($.readText(`${cspSource}/${x}`), x)).join('\n\n').replace(/([(,])\s*\r?\n\s*/g, '$1 ');
  const prepared = processMacros(data);
  prepared.replace(/LUATYPEDEF\(\s*([\w:]+)\s*,\s*(\w+)\s*\)/g, (_, k, v) => { /* console.log(k, v); */ luaTypes[k] = v });

  function splitArgs(name, args) {
    let defaultMap = {};
    args = args.replace(/\(.*?\)|\{.*?\}|\/\*.*?\*\//g, _ => {
      const key = (_[0] == '/' ? '@@' : '') + Math.random().toString(32).substr(2);
      defaultMap[key] = _;
      return key;
    });
    const unwrap = x => {
      for (let k in defaultMap) {
        x = x.replace(k, defaultMap[k]);
      }
      return x;
    };

    const ret = args.split(',')
      .filter(x => x)
      .map((x, i) => {
        if (/^([^=]+)\s+(\w+)(?:\s*=\s*([^@]+))?(?:\s*(@@\w+)?)?$/.test(x)){
          // if (RegExp.$2 == 'uv_size') $.echo(RegExp.$3, unwrap(RegExp.$4));
          const type = RegExp.$1.trim();
          const name = RegExp.$2.trim();
          const defaultBase = RegExp.$3.trim();
          const commentBase = RegExp.$4.trim();
          return { index: i, type, name, 
            default: defaultValueToLua(unwrap(defaultBase)), 
            comment: unwrap(commentBase).replace(/^\/\*\s*|\s\*\/$/g, '') 
          };
        }
        $.fail(`failed to parse argument: “${x}”`)
      })
      .filter(x => x);
    ret.forEach(x => extendArg(x, name, ret, opts.customTypes));
    return ret;
  }

  function wrapDefault(value) {
    if (/\(/.test(value)) {
      const i = localDefines[value];
      return i ? i.key : (localDefines[value] = { key: `__def_${value.replace(/\W+/g, '')}`, value }).key;
    }
    return value;
  }

  prepared.replace(/(?:\/\*@([\s\S]+?)\*\/\s+)?\bLUAEXPORT\s+((?:const\s+)?\w+[*&]?)\s+(lj_\w+)\s*\((.*)/g, (_, docs, resultType, name, argsLine) => {
    let ns = 'ac';
    if (/__(\w+)$/.test(name) && !opts.allows.includes(RegExp.$1)) {
      if (opts.namespaces.includes(RegExp.$1)) {
        ns = RegExp.$1;
      } else {
        return;
      }
    }

    if (/\/\*@/.test(docs)){
      docs = docs.substr(docs.lastIndexOf('/*@') + 3);
    }

    const args = argsLine[0] == ')' ? [] : splitArgs(name, argsLine.split(/\)\s*(\{|$|(?<!:)\/\/)/)[0].trim());
    const comment = /(?<!:)\/\/@?\s+(.+)/.test(argsLine) ? ' // ' + RegExp.$1 : '';
    ffiDefinitions.push(`${typeToLua(resultType)} ${name}(${args.map(x => `${typeToLua(x.type)} ${x.name}`).join(', ')});`);
    if (notForExport(name)) return;

    const cleanName = name.replace(/^lj_|__\w+$/g, '');
    const overloads = [];
    if (docs) docs.replace(/@overload (.+)/g, (_, fn) => {
      if (!/^fun\((.*)\)$/.test(fn)) $.fail(`Incorrect overload: ${_}`);
      overloads.push(RegExp.$1.split(',').map(x => x.split(':').map(y => y.trim())));
    });

    function solveType(type){
      for (let e of opts.enumDefs){
        if (e.params.name == type) {
          if (!e.params.underlying) $.fail(`enum without known underlying type: ${type}`);
          if (e.params.underlying == 'int') return 'number';
          $.fail(`enum with unsupported underlying type: ${type}, ${e.params.underlying}`);
        }
      }
      if (type == 'integer') return 'number';
      return type;
    }

    function typeMatches(value, targetType){
      targetType = solveType(targetType);
      if (isVectorType(targetType)) return `ffi.istype('${targetType}', ${value})`;
      if (/^boolean|string|number$/.test(targetType)) return `type(${value}) == '${targetType}'`;
      $.fail(`unknown type for overload check: ${targetType}`);
    }

    function areTypesSame(type1, type2){
      return solveType(type1) == solveType(type2);
    }

    function resolveOverload(overload, overloadIndex){
      for (let i = 0; i < overload.length; ++i){
        if (overload[i][0] != args[i].name) {
          const overloadType = findLDocType(args[i], opts.enumDefs, ns, cleanName)
          if (areTypesSame(overload[i][1], overloadType)) $.fail(`can’t overload ${name} if types are the same: ${overload}`);

          const o = args.length - overload.length;
          function remapV(j){
            if (j + i < overload.length){
              const n = overload[j + i];
              const f = args.filter(x => x.niceName == n[0])[0];
              if (!f) $.fail(`can’t overload ${name}: failed to match ${n[0]}: ${n[1]}`);
              if (findLDocType(f, opts.enumDefs, ns, cleanName) != n[1]) $.fail(`can’t overload: ${name} types of ${n[0]} don’t match (${n[1]} ≠ ${findLDocType(f, opts.enumDefs, ns, cleanName)})`);
              return f.name;
            }
            return args[i + (j + o) % (args.length - i)].name;
          }

          return `${overloadIndex > 0 ? 'elseif' : 'if'} ${typeMatches(args[i].name, overload[i][1])} then 
            ${args.slice(i).map((x, j) => remapV(j)).join(', ')} = ${args.slice(i).map((x, j) => i + j >= overload.length ? 'nil' : args[i + j].name).join(', ')} 
          ${overloadIndex < overloads.length - 1 ? '' : 'end'}`;
        }
      }
      return `opt("${overload}")`;
    }

    if (args.length > 0 || needsWrappedResult(resultType)) {
      const prepared = args.map(x => prepareParam(x, wrapDefault, localDefines)).map(x => ({ x, i: !isStatementPrepare(x) }));
      const wrapResultCallback = wrapResult(resultType);
      const wrapResultPrefix = wrapResultCallback.extraData == null ? '' : wrapResultCallback.extraData(cleanName) + '\n';
      exportEntries.push(`${wrapResultPrefix}${ns}.${cleanName} = function(${args.map(x => x.name).join(', ')}) 
        ${args.map(x => /\bfun\(/.test(x.comment) ? `${x.niceName} = __util.setCallback(${x.niceName})` : null).filter(x => x).join('\n') }
        ${overloads.map(resolveOverload).join('\n')}
        ${prepared.filter(x => !x.i).map(x => x.x).join(' ')} 
        ${wrapResultCallback.callback(`ffi.C.${name}(${args.map((x, i) => prepared[i].i ? prepared[i].x : x.name).join(', ')})`, cleanName)} 
      end`);
      docDefinitions.push(`${ns}.${cleanName}(${args.map(x => wrapParamDefinition(x)).join(', ')})${wrapReturnDefinition(resultType, opts.customTypes)}${comment}`);

      docDeclarations.push(wrapReturnLComment(docs, comment));
      args.forEach(a => docDeclarations.push(wrapParamLDoc(a, opts.enumDefs, ns, cleanName)));
      docDeclarations.push(wrapReturnLDoc(resultType, opts.customTypes, docs, comment));
      docDeclarations.push(`function ${ns}.${cleanName}(${args.map(x => x.niceName).join(', ')}) end\n`);
    } else {
      exportEntries.push(`${ns}.${cleanName} = ffi.C.${name}`);
      docDefinitions.push(`${ns}.${cleanName}()${wrapReturnDefinition(resultType, opts.customTypes)}${comment}`);

      docDeclarations.push(wrapReturnLComment(docs, comment));
      docDeclarations.push(wrapReturnLDoc(resultType, opts.customTypes, docs, comment));
      docDeclarations.push(`function ${ns}.${cleanName}() end\n`);
    }
  });

  function getKeyword(expr){
    expr = expr.split('//')[0].trim();
    if (expr[expr.length - 1] != ')') return {e1:expr};
    // const i = expr.lastIndexOf(',');
    // if (i == -1) return {e2:expr};
    if (/(?:LUAFIELD_SET|LUASTATIC_SET)\([\w:]+, [\w:]+, ([\s\S]+)\)/.test(expr)) return RegExp.$1;
    if (/(?:LUAFIELD_ARRAY_FILL|LUAFIELD_ARRAY_STRUCT)\([\w:]+, \d+, [\w:]+, ([\s\S]+)\)/.test(expr)) return RegExp.$1;
    if (/LUASTATIC_SET_KEY\([\w:]+, [\w:]+, ([\s\S]+), [^,]+\)/.test(expr)) return RegExp.$1;
    // return expr.substr(i + 1);
    return {e2:expr};
  }

  if (opts.states.length > 0) {
    for (let name of opts.states) {
      stateExtras = '';
      $.readText(`${cspSource}/${name}`).replace(/\bLUASTRUCT\s+(\w+)([\s\S]+?)\n(?:\t| {4})\};/g, (_, name, content) => {
        const fields = [];
        const ldFields = [];
        const cppStatic = [];
        const cppUpdate = [];
        const cppFields = {};
        content.replace(/\bLUA(\w+)\((.+)/g, (_, keys, data) => {
          let comment = '', ldocComment = '';
          if (/^(.+)(?<!:)\/\/\s*(.+)$/.test(data)) {
            data = RegExp.$1;
            comment = ' // ' + RegExp.$2;
            ldocComment = ' @' + wrapLDocSentence(RegExp.$2);
          }

          const isStatic = /STATIC/.test(keys);
          const isDynArray = /DYNARRAY/.test(keys);
          const isArray = /ARRAY/.test(keys);
          let match = data.trim().match(isDynArray ? /(\w+), ([^,]+), (\w+), (.+)\)$/ : isArray ? /(\w+), (\d+), (\w+), (.+)\)$/ : /(\w+), (\w+), (.+)\)$/);
          if (!match && !isArray) match = data.trim().match(/(\w+), (\w+), \[&]\{$/);
          if (!match) $.fail(`failed to match field data: “${data}”`);

          fields.push(isDynArray ? `const ${baseTypeToLua(match[1])}* ${match[3]};${comment}` 
            : isArray ? `const ${baseTypeToLua(match[1])} ${match[3]}[${match[2]}];${comment}`
            : `const ${baseTypeToLua(match[1])} ${match[2]};${comment}`);

          if (isArray){
            if (isDynArray){
              if (!ldocComment) ldocComment = ` @Items start with 0. Be careful not to get outsize of number of items, for performance reasons there is no check.`;
              else ldocComment = `${ldocComment} Items start with 0. Be careful not to get outsize of number of items, for performance reasons there is no check.`;
            } else {
              if (!ldocComment) ldocComment = ` @${match[2]} items, starts with 0.`;
              else ldocComment = `${ldocComment} ${match[2]} items, starts with 0.`;
            }
          } else if (match[1] === 'lua_vector_int'){
            if (!ldocComment) ldocComment = ` @Items start with 0. To get number of elements, use \`#state.${match[2]}\``;
            else ldocComment = `${ldocComment} Items start with 0. To get number of elements, use \`#state.${match[2]}\``;
          }

          if (!/@hidden\b/.test(ldocComment)) {
            const kw = getKeyword(_);
            if (typeof(kw) === 'string'){
              if (cppFields[kw]){
                $.echo(β.yellow(`\tPossible repetition: ${_} (${kw})`))
              } else {
                cppFields[kw] = true;
              }
            } else if (kw !== false) {
              $.echo(β.yellow(`\tCouldn’t find keyword: ${_} (${JSON.stringify(kw)}`))
            }

            ldFields.push(isArray
              ? `---@field ${match[3]} ${getTypeInfo(match[1], opts.customTypes).name}[]${ldocComment}`
              : `---@field ${match[2]} ${getTypeInfo(match[1], opts.customTypes).name}${ldocComment}`);
          }
          (isStatic ? cppStatic : cppUpdate).push(`${match[isArray ? 3 : 2]}_set(c);`);
        });

        docDefinitions.push(`\nstruct ac.${toNiceName(name, true)} {\n\t${fields.join('\n\t')}\n}`);
        docDeclarations.push(`\n---@class ac.${toNiceName(name, true)} : ClassBase`, ...ldFields);
        ffiStructures.push(`typedef struct {\n\t${fields.join('\n\t')}\n} ${name};`);

        if (!stateDefinitionsUpdated.hasOwnProperty(name)) {
          if (/void init\((.*?)\)/.test(content)) {
            const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
            const argNames = args.map(x => x.split(' ').slice(-1)[0]);
            const ctxInit = /\bstruct\s+init_ctx\b/.test(content) ? `\n\t\tconst init_ctx c{${argNames}};` : '';
            stateExtras += `\n\tvoid ${name}::init(${args})\n\t{${ctxInit}\n\t\t${cppStatic.join('\n\t\t')}\n\t}\n`
          }

          if (/void update\((.*?)\)/.test(content)) {
            const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
            const argNames = args.map(x => x.split(' ').slice(-1)[0]);
            const ctxInit = /\bstruct\s+ctx\b/.test(content) ? `\n\t\tconst ctx c{${argNames}};` : '';
            if (cppStatic.length > 0) {
              stateExtras += `\n\tvoid ${name}::update(${args})\n\t{\n\t\tif (needs_initialization()) init(${argNames});${ctxInit}\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
            } else {
              stateExtras += `\n\tvoid ${name}::update(${args})\n\t{${ctxInit}\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
            }
          }
        }
      });

      if (stateExtras) {
        let oldData = $.readText(`${cspSource}/${name}`);
        let newData = oldData.split('// Generated automatically:')[0].trim()
          + `\n\n// Generated automatically:\nnamespace lua\n{${stateExtras}\n}\n`;
        if (oldData != newData) {
          $.echo(β.grey(`  State definitions updated: ${name}`));
          fs.writeFileSync(`${cspSource}/${name}`, newData);
        }
        stateDefinitionsUpdated[name] = true;
      }
    }
  }

  var gets = {};
  data.replace(/\bLUAGETSET\w*\(([^,]+), (\w+?)_(\w+)/g, (_, type, group, name) => {
    (gets[group] || (gets[group] = [])).push(name);
  });

  for (var n in gets) {
    exportEntries.push(`ac.${n} = {}
    setmetatable(ac.${n}, {
      __index = function (self, k) 
        ${gets[n].map(x => `if k == '${x}' then return ffi.C.lj_get${n}_${x}() else`).join('')}
        error('${n} does not have an attribute “'..k..'”', 2) end
      end,
      __newindex = function (self, k, v) 
        ${gets[n].map(x => `if k == '${x}' then ffi.C.lj_set${n}_${x}(v) else`).join('')}
        error('${n} does not have an attribute “'..k..'”', 2) end
      end,
    })`);
  }

  function enBit(v){
    const i = Object.values(v);
    if (i.includes(1) && i.includes(2) && i.includes(4) && i.includes(8) && !i.includes(3) && !i.includes(5)) return true;
    return false;
  }

  function enVal(v, b){
    if (v == null) throw new Error('v is null');
    if (b && typeof(v) === 'number') return '0x' + v.toString(16);
    return JSON.stringify(v).replace(/"/g, '\'');
  }

  function enCom(c, n, k, v, b){
    if (c) c = c.replace(/@opt/, '').trim()

    if (!c) {
      if (b && v == 0) return 'No special options.'
      return 'Value: ' + enVal(v, b) + '.';
    }
    c = c.trim().replace(/^[a-z]/, _ => _.toUpperCase()).replace(/,$/, '');
    if (c.indexOf('|') !== -1) c = `Combination of flags: ${c.replace(/^\s*\!\[|[.!?]$/, '')} (use \`bit.bor(${k}.${n}, …)\` to combine it with other flags safely).`;
    else if (!/^\s*\!\[|[.!?]$/.test(c)) c = c + '.';
    return c;
  }

  if (definitionsCallback) {
    opts.luaSources.forEach(i => {
      const dlua = i.replace(/\.lua$/, '.d.lua');
      if (fs.existsSync(dlua)) {
        const data = prepareLDoc(jsMacroEngine(fs.readFileSync(dlua), { ldoc: true, flags: opts.flags }).trim());
        if (data) {
          if (/^---@meta/.test(data)) {
            docDeclarations.splice(0, 0, `\n--[[ ${i.replace(/\.\//g, '')} ]]\n`, data.replace(/^---@meta\s+/, '').trim());
          } else {
            docDeclarations.push(`\n--[[ ${i.replace(/\.\//g, '')} ]]\n`);
            docDeclarations.push(data.trim());
          }
        }
      }
      if (fs.existsSync(i)) {
        const data = prepareLDoc(jsMacroEngine(fs.readFileSync(i), { ldoc: true, flags: opts.flags })).split('\n');
        const collected = [], collectedFinal = [];
        const registeredClasses = {};
        for (let i = 0; i < data.length; ++i) {
          const l = data[i];
          if (/^---(?!@diagnostic)/.test(l)) {
            collectedFinal.push(...collected);
            collected.length = 0;
            collected.push('\n' + l);
            for (++i; i < data.length; ++i) {
              const l1 = data[i].trim();
              if (!l1) {
                const type = collected.map(x => /---@class ([\w.]+)/.test(x) ? RegExp.$1 : null).filter(x => x).slice(-1)[0];
                if (!collected.some(x => /---@(constructor|explicit-constructor|virtual-class)/.test(x))){
                  if (type) collected.push(`---@virtual-class ${type}`);
                }
                break;
              }
              if (/^--/.test(l1)) {
                collected.push(l1);
              } else if (/(\S+)\s*=\s*__enum\(/.test(l1)) {
                opts.enumDefs.forEach(i => {
                  if (i.params.name == RegExp.$1){
                    i.comment = collected.join('');
                  }
                })
                collected.length = 0;
                break;
              } else if (/^(function .+?\))/.test(l1)) {
                collected.push(`${RegExp.$1} end`);
                break;
              } else if (/\bffi\.cdef/.test(l1)) {
                continue;
              } else if (/(?:(local\s+)?([\w.]+) = )?\bffi\.metatype\(/.test(l1)) {
                const localConstructor = !!RegExp.$1;
                const constructorName = RegExp.$2;
                const type = collected.map(x => /---@class ([\w.]+)/.test(x) ? RegExp.$1 : null).filter(x => x).slice(-1)[0] || '?';
                if (type == '?') {
                  $.echo(β.red(collected.join('\n')));
                }

                // if (!collected.some(x => /---@(type|return)/.test(x)) && constructorName && !localConstructor) {
                //   collected.push('');
                  
                //   const args = collected.map(x => /---@field ([\w.]+) ([\w.]+)/.test(x) ? `${RegExp.$1} ${RegExp.$2}` : null).filter(x => x);
                //   if (args.length > 5) args.length = 0;
                //   for (let a of args){
                //     collected.push(`---@param ${a}`);
                //   }
                //   collected.push(`---@return ${type}`);
                //   collected.push(`function ${type}(${args.map(x => x.split(' ')[0]).join(', ')}) end`);
                // } else {                  
                //   collected.push(`${type} = nil`);
                // }

                if (collected.some(x => /---@(type|return)/.test(x))) {
                  $.fail(`obsolete way: ${type}`)
                }

                if (!collected.some(x => /---@(constructor|explicit-constructor|virtual-class)/.test(x))){
                  if (constructorName && !localConstructor) {
                    function prepareComment(comment){
                      if (!comment) return '';
                      if (comment[0] == '@') return JSON.stringify(comment.substr(1));
                      return comment;
                    }
                    const args = collected.map(x => /---@field ([\w.]+) ([\w.]+)(?:\s+(@.+|".+"))?/.test(x) ? `${RegExp.$1}: ${RegExp.$2}${prepareComment(RegExp.$3)}` : null).filter(x => x);
                    collected.push(`---@constructor fun(${args.length < 6 ? args.join(', ') : ''}): ${type}`);
                  } else {
                    // $.echo(β.red(type))
                    collected.push(`---@virtual-class ${type}`);
                  }
                }

                if (constructorName && constructorName != type) {
                  $.fail(`class type mismatch: ${constructorName} ≠ ${type}`)
                }
                const fn = [];
                if (!/\}\)\s*$/.test(l1)) {
                  for (++i; i < data.length; ++i) {
                    const l2 = data[i];
                    if (/^\s+(---.*)/.test(l2)) {
                      fn.push(RegExp.$1);
                    } else {
                      if (/^\s+(\w+) = function\s*\(s(?:,\s+(.*?))?\)/.test(l2)) {
                        if (RegExp.$1[0] == '_') continue;
                        collected.push('', ...fn);
                        collected.push(`function ${type}:${RegExp.$1}(${RegExp.$2}) end`);
                      } else if (/^\s+(\w+) = function\s*\((.*?)\)/.test(l2)) {
                        if (RegExp.$1[0] == '_') continue;
                        $.echo(β.grey(`\tStatic method: ${type}.${RegExp.$1}(${RegExp.$2})`));
                        collected.push('', ...fn);
                        collected.push(`function ${type}.${RegExp.$1}(${RegExp.$2}) end`);
                      } else if (/^\s+(\w+) = ffi\.C\.\w+/.test(l2)) {
                        collected.push('', ...fn);
                        collected.push(`function ${type}:${RegExp.$1}() end`);
                      } else if (fn.length > 0) {
                        $.echo(β.red(`  Unexpected class method: ${l2}`))
                      }
                      if (/^\s*(\}\s*)?\}\)\s*$/.test(l2)) {
                        break;
                      }
                      fn.length = 0;
                    }
                  }
                }
                break;
              } else if (/^[\w.]+ = (?!function)/.test(l1)) {
                collected.push(l1);
                break;
              } else if (/local (\w+) = class\(/.test(l1)) {
                collected.push(l1);
                registeredClasses[RegExp.$1] = true;
                break;
              } else {
                $.fail(`unexpected LDoc line: ${l1}\nstarted: “${l}”\ncollected:${collected.join('\n')})`)
              }
            }
          } else if (/\bfunction (\w+)([.:]\w+\(.*\))/.test(l)){
            if (registeredClasses[RegExp.$1] && !RegExp.$2.startsWith('.allocate(') && !RegExp.$2.startsWith('.recycled(')){
              collectedFinal.push(`function ${RegExp.$1}${RegExp.$2} end`);
            }
          }
        }
        collectedFinal.push(...collected);
        if (collectedFinal.length > 0) {
          docDeclarations.push(`\n--[[ ${i.replace(/\.\//g, '')} ]]`, ...collectedFinal);
        }
      }
    });

    if (opts.enumDefs.length > 0) {
      docDeclarations.splice(0, 0, '\n--[[ enums.lua ]]', ...
        opts.enumDefs.map(i => {
          const b = enBit(i.values);
          const v = Object.entries(i.values).filter(v => !i.comments[v[0]] || !/@hidden/.test(i.comments[v[0]])).map(v => `  ${v[0]} = ${enVal(v[1], b)},${' ---' + enCom(i.comments[v[0]], v[0], i.params.name, v[1], b)}`)
          if (v.length === 0) $.fail('empty enum: ' + i.params.name)
          return `${i.comment ? i.comment : ''}
---@alias ${i.params.name}${Object.entries(i.values).filter(v => !i.comments[v[0]] || !/@(?:opt|hidden)/.test(i.comments[v[0]])).map(v => `\n---| '${i.params.name}.${v[0]}' @${enCom(i.comments[v[0]], v[0], i.params.name, v[1], b)}`).join('')}
${i.params.name} = {\n${v.join('\n')}\n}`
        }))
    }

    definitionsCallback(docDefinitions.join('\n'), docDeclarations.filter(x => x != null).join('\n'));
  }

  const localDefineKeys = Object.values(localDefines);
  localDefineKeys.sort((a, b) => a.key > b.key ? 1 : -1);

  return `ffi.cdef [[ DEFINITIONS ]] EXPORT`
    .replace(/\bDEFINITIONS\b/, '\n' + ffiStructures.join('\n') + ffiDefinitions.join('\n') + '\n')
    .replace(/\bEXPORT\b/, localDefineKeys.map(x => `local ${x.key} = ${x.value}`).join('\n') + exportEntries.join('\n'));
}

function solveFlags(code, flags){  
  // no longer used atm
  return code.toString().replace(/--\[\[\s+if\s+(.+?)\s*\[\[\s*([\s\S]+?)\s*\]\]\s*/g, (_, k, v) => {
    try {
      if (eval(`(function(${Object.keys(flags)}){ return ${k}; })`)(...Object.values(flags))) {
        return v + '\n';
      } else {
        return '';
      }
    } catch (e) {}
  });
}

// const contextBase = null;

function resolveRequires(code, filename, context = null) {
  const refDir = filename ? filename.replace(/[\/\\][^\/\\]+$/, '') : null;

  const mainNode = context == null;
  if (mainNode) {
    resetTypes();
    context = {
      toInsertPre: [],
      toInsertPost: [],
      processed: {},
      definitions: {
        luaSources: [filename],
        sources: [],
        states: [],
        allows: [],
        namespaces: [],
        postCdefs: [],
        customTypes: {},
        enumDefs: [],
        flags: {}
      }
    };
    context.specialCalls = {
      __source: context.definitions.sources,
      __states: context.definitions.states,
      __allow: context.definitions.allows,
      __namespace: context.definitions.namespaces,
      __post_cdef: context.definitions.postCdefs
    };
  }

  if (context.definitions != null) {
    // code.replace(/--\[\[\s+set\s+(\w+)\s*=\s*(\S+?)\s*\]\]/g, (_, k, v) => context.definitions.flags[k] = eval(`(${v})`));
    // code = solveFlags(code, context.definitions.flags);
    code = jsMacroEngine(code, { flags: context.definitions.flags });
  }

  let ast;
  try {
    ast = parser.parse(code);
  } catch (e) {
    fs.writeFileSync('.out/failed.lua', code);
    throw e;
  }

  function requireFnName(callRequire) {
    const filename = refDir + '/' + callRequire + '.lua';
    if (context.definitions == null && !/\/secure\.lua$/.test(filename)) {
      $.echo(β.red(`  Including post definitions: ${filename}, LDoc entries will be ignored`))
    }
    // $.echo(β.grey(`  Include: ${filename}`));
    if (fs.existsSync(filename)) {
      const fnName = '__' + callRequire.replace(/.+[\\//]/, '').replace(/\W+/g, '');
      if (context.processed[fnName]) return null;
      context.processed[fnName] = true;
      if (context.definitions) context.definitions.luaSources.push(filename);
      return { fnName, filename };
    } else {
      $.fail('Not found: ' + filename);
    }
  }

  function isStringCallExpression(p, nameTest) {
    if (p.base && p.base.type == 'Identifier' && nameTest(p.base.name)
      && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral'
        || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')) {
      return (p.argument || p.arguments[0]).value;
    }
    return false;
  }

  function processStatement(p) {
    function isStringCall(nameTest) {
      if (p.type === 'CallStatement' && p.expression && isStringCallExpression(p.expression, nameTest)) {
        return (p.expression.argument || p.expression.arguments[0]).value;
      }
      return false;
    }

    if (p.type === 'CallStatement' && p.expression && p.expression.base && p.expression.base.name === '__definitions') {
      if (context.definitions == null) $.fail(`definitions are processed already (__definitions, ${filename})`);
      const code = getLuaCode(context.definitions, (definitions, declarations) => {
        const name = path.basename(filename, '.lua');
        fs.writeFileSync(`.definitions/${name}.txt`, definitions)
        if (path.basename(filename) == 'ac_common.lua') {
          commonDeclarations = declarations + '\n';
        } else {
          saveLDocLib(`${process.env['LUA_OUTPUT']}/${name}`, `---@meta\n---@diagnostic disable: lowercase-global\n\n${commonDeclarations.trim()}\n\n${declarations.trim()}`);
        }
      });
      context.definitions = null;
      return resolveRequires(code, null, context).body;
    }

    if (p.type == 'AssignmentStatement'
      && p.variables.length === 1 && p.variables[0].type === 'MemberExpression'
      && p.init.length === 1 && p.init[0].type === 'CallExpression' && p.init[0].base.type === 'MemberExpression'
      && p.init[0].base.base.name === 'ffi' && p.init[0].base.identifier.name === 'metatype') {
      if (context.definitions == null) $.fail(`definitions are processed already (ffi.metatype, ${filename})`);
      const typeName = p.variables[0].base.name + p.variables[0].indexer + p.variables[0].identifier.name;
      const typeValue = p.init[0].arguments[0].value;
      context.definitions.customTypes[typeValue] = typeName;
    }

    function resolveConst(v){
      if (v.type === 'NumericLiteral' || v.type === 'StringLiteral' || v.type === 'BooleanLiteral') return v.value;
      if (v.type === 'UnaryExpression' && v.operator === '-') return -resolveConst(v.argument);
      return v.value || console.log(v);
    }

    function resolveName(v){
      if (v.type === 'MemberExpression') return resolveName(v.base) + '.' + resolveName(v.identifier);
      if (v.type === 'Identifier') return v.name;
      return v.base.name + v.indexer + v.identifier.name;
    }

    if (p.type == 'AssignmentStatement'
      && p.variables.length === 1 && p.variables[0].type === 'MemberExpression'
      && p.init.length === 1 && p.init[0].type === 'CallExpression' && p.init[0].base.type === 'Identifier'
      && p.init[0].base.name === '__enum' && p.init[0].arguments.length == 2) {
      const args = p.init[0].arguments.map(x => x.fields.reduce((a, b) => (a[b.key.name] = resolveConst(b.value), a), {}));
      if (args[0].name == null) args[0].name = resolveName(p.variables[0]);
      if (args[0].min == null) args[0].min = Object.values(args[1]).reduce((a, b) => Math.min(a, b), Number.POSITIVE_INFINITY);
      if (args[0].max == null) args[0].max = Object.values(args[1]).reduce((a, b) => Math.max(a, b), Number.NEGATIVE_INFINITY);
      if (args[0].default == null) args[0].default = Object.values(args[1])[0];
      if (args[0].underlying == null) args[0].underlying = 'int';
      if (args[0].override) {
        args[0].override = new RegExp(args[0].override.replace(/[-\/\\^$+?.()|[\]{}]/g, '\\$&').replace(/\*/g, '.+'));
      }
      args[0].resolveValue = function (value) {
        if (/::(\w+)$/.test(value)) {
          const key = RegExp.$1;
          for (let k in this) if (k.toLowerCase() == key) return this[k];
        }
        if (/^Im.+_(\w+)$/.test(value)) {
          const key = RegExp.$1;
          for (let k in this) if (k == key) return this[k];
        }
        if (/^\d+$/.test(value)) {
          for (let k in this) if (this[k] == value) return this[k];
        }
        $.fail(`building script needs more work on mapping Lua enum names to C++ names:\nValue: ${value}\nDef: ${JSON.stringify(this)}`);
      }.bind(args[1]);
      enumTypes[args[0].cpp] = args[0];
      p.init[0] = p.init[0].arguments[1];
      let comments = null;
      code.replace(new RegExp(`${args[0].name} = __enum\\(([\\s\\S]+?)\\n\\s*\\}\\)`), (_, c) => {
        comments = c.split('}, {')[1].split('\n').map(x => x.split(/=|--/).map(y => y.trim())).reduce((c, p) => (p[2] && (c[p[0]] = p[2]), c), {});
      });
      if (!comments) {
        $.fail(`failed to find enum values: ${args[0].name}`);
      }
      context.definitions.enumDefs.push({ params: args[0], values: args[1], comments });
      if (args[0].override) enumOverrides.push(context.definitions.enumDefs[context.definitions.enumDefs.length - 1]);
      return p;
    }

    let callSpecialName = null;
    let callSpecialArg = isStringCall(x => /^__/.test(callSpecialName = x));
    const callSpecialList = context.specialCalls[callSpecialName];
    if (callSpecialList != null) {
      if (context.definitions == null) $.fail(`definitions are processed already (${callSpecialName}, ${callSpecialArg}, ${filename})`);
      if (callSpecialArg === false) {
        context.toInsertPost.push(...p.expression.arguments[0].body);
      } else if (!callSpecialList.includes(callSpecialArg)) {
        callSpecialList.push(callSpecialArg);
      }
      return null;
    }

    const callRequire = isStringCall(x => x === 'require');
    if (callRequire) {
      if (requireToIgnore(callRequire)) return;
      const ready = requireFnName(callRequire);
      if (!ready) return null;
      return resolveRequires($.readText(ready.filename), ready.filename, context).body;
    }
  }

  function processPiece(p) {
    if (minifyFfiDefinitions && p.base && p.base.type == 'MemberExpression' && p.base.indexer == '.' && p.base.identifier.name == 'cdef'
      && p.base.base.name == 'ffi' && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral'
        || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')) {
      (p.argument || p.arguments[0]).raw = JSON.stringify(crunchC((p.argument || p.arguments[0]).value));
      return true;
    }

    const callRequire = isStringCallExpression(p, x => x === 'require');
    if (callRequire) {
      if (requireToIgnore(callRequire)) return;
      if (callRequire == './ac_common') {
        (p.argument || p.arguments[0]).raw = JSON.stringify('extension/lua/ac_common');
        return true;
      }

      const ready = requireFnName(callRequire);
      if (ready == null) return null;

      const resolved = resolveRequires($.readText(ready.filename), ready.filename, context);
      context.toInsertPre.push({
        type: 'FunctionDeclaration',
        identifier: { type: 'Identifier', name: ready.fnName, isLocal: true },
        isLocal: true,
        parameters: [],
        body: resolved.body
      });
      return {
        type: 'CallExpression',
        base: { type: 'Identifier', name: ready.fnName, isLocal: true },
        arguments: []
      };
    }
  }

  function resolve(piece, forceExpressionMode) {
    if (!Array.isArray(piece) || forceExpressionMode) {
      for (let n in piece) {
        const p = piece[n];
        if (!piece[n] || typeof piece[n] !== 'object') continue;

        const r = processPiece(p);
        if (r) {
          if (r !== true) piece[n] = r;
        } else if (r === null || resolve(p, n !== 'body') === false) {
          return false;
        }
      }
    } else {
      for (let i = 0; i < piece.length; ++i) {
        const p = piece[i];
        const r = processStatement(p);
        if (r) {
          if (r !== true) {
            const j = Array.isArray(r) ? r : [r];
            piece.splice(i, 1, ...j);
            i += j.length - 1;
          }
        } else if (r === null || resolve(p) === false) {
          piece.splice(i--, 1);
        }
      }
    }
  }

  resolve(ast);
  if (mainNode) {
    ast.body = context.toInsertPre.concat(ast.body).concat(context.toInsertPost);
  }

  return ast;
}

function guessDefaultLDocValue(item, hint){
  if (hint && hint[0] != '(') return hint;

  if (item.endsWith('[]')) return `{ ${hint || ''} }`;
  if (/^(?:vec|rgb)/.test(item)) return item + (hint || '()');

  if (hint) return hint;
  if (item == 'number' || item == 'integer') return 0;
  if (item == 'string') return "''";

  if (/fun\((.*)\)(?::\s*(\S+))?/.test(item)){
    const a = RegExp.$1.replace(/:.+?(?=,|$)/g, '');
    const r = RegExp.$2 ? `return ${guessDefaultLDocValue(RegExp.$2)}` : '';
    return `function (${a}) ${r} end`
  }
  
  $.echo(β.red(`\tUnknown type to guess default LDoc value for (in tableparam): ${item}`));
  return '';
}

function prepareLDocTableParam(_, i, ldoc, comments, namePrefix){
  let defaultMap = {};
  i = i.replace(/\(.*?\)|\{.*?\}|".*?"/g, _ => {
    let key = Math.random().toString(32).substr(2);
    if (_[0] == '"') key = `"${key}"`;
    defaultMap[key] = _;
    return key;
  });
  const unwrap = x => {
    if (!x) return x;
    for (let k in defaultMap) {
      x = x.replace(k, defaultMap[k]);
    }
    return x;
  };

  const a = i.split(',').map(x => {
    if (!/^\s*(\w+)\s*:\s*([\w.[|()\]]+)\s*(?:=\s*(".*?"|[^"]+))?(\s*".+"\s*)?$/.test(x)) $.fail(`incorrectly formatted parameter: ${_} (${x})`);
    const n = RegExp.$1;
    const t = unwrap(RegExp.$2);
    const v = unwrap(RegExp.$3.trim());
    const l = unwrap(RegExp.$4.trim());
    if (l){
      comments.push({ name: namePrefix ? `${namePrefix}.${n}` : n, comment: JSON.parse(l) });
    }

    if (t[0] == '{' && t[t.length - 1] == '}'){
      let f2 = [];
      const p = prepareLDocTableParam(_, t.substr(1, t.length - 2), f2, comments, namePrefix ? `${namePrefix}.${n}` : n);
      ldoc.push(`${n}: {${f2.join(', ')}}`);
      return `${n} = ${p}`;
    }

    ldoc.push(`${n}: ${t}`);

    if (v == 'nil'){
      return null;
    }
    return `${n} = ${guessDefaultLDocValue(t, v)}`;
  });
  return `{ ${a.filter(x => x).join(', ')} }`;
}

function fixLDocCommentStyle(s){
  if (s[0] == '"') return JSON.stringify(wrapLDocSentence(JSON.parse(s)));
  if (s[0] == '@') return '@' + wrapLDocSentence(s.substr(1));
  $.fail(`wrong comment format: ${s}`);
}

function parseLDocComment(s){
  if (s[0] == '"') return JSON.parse(s);
  if (s[0] == '@') return s.substr(1);
  return s;
}

function formatLDocDefaultTable(s){
  if (s.length < 60) return s;

  let r = '';
  let m = '';
  let b = 0;
  for (let i = 0; i < s.length; ++i){
    let c = s[i];
    if (c == ' ' && s[i + 1] == '}') { ++i; c = '}'; }
    if (c == '}') { m = m.substr(2); r += '\\n' + m; }
    r += c;
    if (c == '{') { m += '  '; r += '\\n' + m; if (s[i + 1] == ' ') ++i; }
    if (c == '(') { ++b; }
    if (c == ')') { --b; }
    if (c == ',' && b == 0) { r += '\\n' + m; if (s[i + 1] == ' ') ++i; }
  }
  return r;
}

function prepareLDoc(content){  
  content = content.replace(/\r/g, '');
  content = content.replace(/--\[\[(@\w+[\s\S]+?)\]\]/g, (_, v) => '---' + v.replace(/\n\s*/g, ' ')).replace(/\\\n---\s*/g, '');
  content = content.replace(/---@class\s+(\S+).*(?:\n---.*)*?\n---@cpptype\s+(\S+)/g, (_, cp, c) => {
    if (knownLDocTypes[c] && knownLDocTypes[c] != cp) $.fail(`Conflict: ${cp} ≠ ${knownLDocTypes[c]}`);
    knownLDocTypes[c] = cp;
    return _.replace(/\n---@cpptype\s+.+/, '')
  });
  content = content
    .replace(/(---@(?:tableparam|param)\s+\w+\s+)\{([^@\n]+) *(.*)/g, (_, prefix, def, comment) => {
      def = def.trim();
      if (!def.endsWith('}')) return _;

      def = def.substr(0, def.length - 1);
      let ldoc = [];
      let comments = [];
      let s = prepareLDocTableParam(_, def, ldoc, comments);

      if (!/tableparam/.test(prefix)){
        $.echo(β.yellow(`\tDefault table parameter: ${_}`));
      }

      if (comments.length > 0) {
        if (!comment) comment = 'Properties:'
        else comment = `${wrapLDocSentence(parseLDocComment(comment))} Properties:`
        for (let c of comments) comment = `${comment}\n- \`${c.name}\`: ${wrapLDocSentence(c.comment)}`
      }

      return `${prefix.replace('tableparam', 'param')}{${ldoc.join(', ')}} | "${formatLDocDefaultTable(s)}"${comment ? ' ' + JSON.stringify(comment) : ''}`;
    });
    
  if (/---@tableparam (.+)/.test(content)){
    $.fail(`failed to parse properly: ${RegExp.$1}`);
  }

  const d = {};
  content.replace(/(?:---(?!@).*\n)+---@class\s+([\w.]+).*(?:\n---.*)*/g, (_, name) => {
    if (d[name]) $.fail(`unexpected repetition: ${_}`);
    let r = _.replace(/\s+---@class[\s\S]+/, '');
    if (/@deprecated/.test(_)) r += '\n---@deprecated';
    d[name] = r;
  });

  content = content.replace(/(---(?!@).+\n)*(?:---@param.+\n)*---@return\s+([\w.]+)\b.*\nfunction\s+([\w.:]+)/g, (_, comment, name, fnName) => {
    if (!comment && name == fnName && d[name]) return d[name] + '\n' + _;
    return _;
  });

  return content;
}

function finalizeLDoc(content, type){
  const renames = {};
  
  function safe(name){
    if (/^\w+$/.test(name)) return name;

    const rename = `_${name.replace(/\W+/g, '_')}`;
    if (renames.hasOwnProperty(rename)) $.fail('Unexpected rename collision: ' + name);
    renames[rename] = name;
    return rename;
  }

  function createConstructor(name, args){
    let defaultMap = {};
    args = args.replace(/"[^"]+"|\(.*?\)|\{.*?\}/g, _ => {
      const key = _[0] == '"' ? `"${Math.random().toString(32).substr(2)}"` : Math.random().toString(32).substr(2);
      defaultMap[key] = _;
      return key;
    });
    const unwrap = x => {
      for (let k in defaultMap) {
        x = x.replace(k, defaultMap[k]);
      }
      return x;
    };

    const a = args.split(',').filter(x => x).map(x => {
      if (!/\s*(\w+)\s*:\s*(\w+)\s*(".+")?/.test(x)) {
        // $.echo(JSON.stringify(args));
        $.fail(`incorrectly formatted constructor argument: ${x}`);
      }
      return `---@param ${unwrap(RegExp.$1)} ${unwrap(RegExp.$2)} ${unwrap(RegExp.$3)}\n`
    }).join('');
    return `${a}---@return ${name}\nfunction ${name}(${args.replace(/:[^,)]+/g, '')}) end`
  }

  content = (content + '\n')
    .replace(/\r/g, '')
    .replace(/(?:\n---.*)*\n---@constructor\s+fun\((.*)\):\s+([\w.]+)\s+?/g, (_, args, name) => {
      let c = /@class ([\w.]+)/.test(_) ? RegExp.$1 : null;
      if (!c) $.fail('@constructor parse error: ' + name);
      if (c != name) $.fail(`@constructor mismatch: ${name} ≠ ${c}`);
      // $.echo(_);
      let r = `\n${_.split('\n').filter(x => /^---(?!@)/.test(x)).map(x => x + '\n').join('')}${createConstructor(name, args)}\n${_.replace(/\n---@constructor.+|\s+$/g, '')}\n`;
      r += `local ${safe(name)} = nil\n`;
      return r;
    })
    .replace(/---@explicit-constructor ([\w.]+)/g, (_, name) => {
      return `local ${safe(name)} = nil`;
    })
    .replace(/---@virtual-class ([\w.]+)/g, (_, name) => {
      return `local ${safe(name)} = nil`;
    });

  for (let n in renames){
    content = content.replace(new RegExp(`(?<=function )\\b${renames[n].replace(/\./g, '\\.')}\\b(?=[:])`, 'g'), n);

    // Do not rename static methods!
    // content = content.replace(new RegExp(`(?<=function )\\b${renames[n].replace(/\./g, '\\.')}\\b(?=[.])`, 'g'), _ => {
    //   $.echo('REPLACE: ' + n);
    //   return n;
    // });
  }

  if (/\bio\s*=\s*nil\b/.test(content)){
    $.echo(β.grey(`\tNo I/O for you: ${type}`));
  }

  content = content.replace(/(?<=\s)(?:---@param\s+\w+\s+boolean)(?= @|\n)/g, _ => _ + `|'true'|'false'`)
  content = content.replace(/---@.+/g, _ => _.replace(/\s*\|\s*/g, '|'));

  for (let i in knownLDocTypes){
    content = content.replace(new RegExp(`\\b${i}\\b`, 'g'), knownLDocTypes[i]);
  }

  return content.replace(/\n\n\n+/g, '\n');
}

function verifyLDocIntegrity(code){
  if (/---@class(.+)\n\s*---@param/.test(code)){
    $.echo(β.red(`\tDon’t you mean @field? ${RegExp.$1}`));
  }

  let referredTypes = {};
  function add(n, ctx){
    // $.echo('CALL: `' + n + '`')
    n = n.trim();
    if (n.endsWith('?')) return add(n.substr(0, n.length - 1), ctx);
    if (n.endsWith('[]')) return add(n.substr(0, n.length - 2), ctx);
    if (n[0] == '{') {
      if (n[n.length - 1] == '}') {
        let s = 1;
        for (let i = 1; i < n.length - 1; ++i){
          i = consumeSpecial(n, i);
          if (n[i] == ':'){
            if (n.substr(s, i - s) == 'error') $.fail(`incorrect use of keyword “error”: ${ctx}`);
            s = i + 1;
          }
          if (n[i] == ',') {
            // $.echo('\tPIECE: `' + n.substr(s, i - s) + '`')
            add(n.substr(s, i - s), ctx);
            s = i + 1;
          }
        }
        add(n.substr(s, n.length - s - 1), ctx);
        return;
      }
      if (n.indexOf('}') === -1) $.fail('Malformed type? ' + n);
    }
    if (n.startsWith('fun(')) {
      let s = 4;
      for (let i = 4; i < n.length; ++i){
        i = consumeSpecial(n, i);
        if (n[i] == ':'){
          if (n.substr(s, i - s) == 'error') $.fail(`incorrect use of keyword “error”: ${ctx}`);
          s = i + 1;
        }
        if (n[i] == ',' || n[i] == ')') {
          add(n.substr(s, i - s), ctx);
          s = i + 1;
        }
      }
      if (n[s] == ':'){
        add(n.substr(s, n.length - s), ctx);
      }
      return;
    }
    if (/^(?:'|T(?:[\dA-Z]|$))/.test(n)) return;
    if (n.startsWith('table<') && n.endsWith('>')){
      for (let i = 6; i < n.length - 1; ++i){
        i = consumeSpecial(n, i);
        if (n[i] == ',') {
          add(n.substr(6, i - 6), ctx);
          add(n.substr(i + 1, n.length - i - 2), ctx);
          return;
        }
      }
      $.fail(`Wrong table: ${n}`);
      return;
    }
    if (n.indexOf(',') !== -1) {
      let s = 0;
      for (let i = 0; i < n.length - 1; ++i){
        i = consumeSpecial(n, i);
        if (n[i] != ',') continue;
        add(n.substr(s, i - s), ctx);
        s = i + 1;
      }
      if (s) {
        add(n.substr(s, n.length - s), ctx);
        return;
      }
    }
    if (n.indexOf('|') !== -1) {
      let s = 0;
      for (let i = 0; i < n.length - 1; ++i){
        i = consumeSpecial(n, i);
        if (n[i] != '|') continue;
        add(n.substr(s, i - s), ctx);
        s = i + 1;
      }
      if (s) {
        add(n.substr(s, n.length - s), ctx);
        return;
      }
    }
    if (n === 'number' || n === 'integer' || n === 'string' || n === 'any' || n === 'table' || n === 'function' || n === 'boolean' || n === 'nil') return;
    if (n[0] == '"' && n[n.length - 1] == '"') return;
    if (!referredTypes[n]) referredTypes[n] = ctx;
  }
  code.replace(/---@(?:(?:type|return)\s+|(?:field|param)\s+\S+\s+)(.+?)(?:\n|@|$| ")/g, (ctx, s) => add(s.trim(), ctx));
  for (let t in referredTypes){
    if (code.indexOf('@class ' + t) === -1 && code.indexOf('@alias ' + t) === -1){
      $.echo(β.red(`\tUnknown type? ${t} (ctx: “${referredTypes[t]}”)`));
    }
  }
  
  code.replace(/--.+/g, '').replace(/[^\.]error(?![(s]).*/g, _ => {
    $.echo(β.red('incorrect use of keyword `error` in LDdoc: ' + _));
  });
  
  code.replace(/---.+/g, _ => {
    if (/\b(?<!a )default value\b/i.test(_) && !/Default value: [`'\d-]/.test(_)) $.echo(β.red('\tMalformed default value: ' + _));
    if (_.indexOf('"') !== -1 && !/\|/.test(_) && !/---@(?:field|param) \w+ .+ ".+"$/.test(_)) $.echo(β.red('\tUnexpected " symbol: ' + _));
  });

  // add(`table|number|string|boolean|nil`);
  // $.echo(JSON.stringify(referredTypes, null, 4));
  // $.fail('stop');
}

function generateLDocMd(content, module){
  function getPD(v){
    if (!v) return '';
    if (v[0] == '@') return ' ' + v.substr(1);
    try {
      return ' ' + JSON.parse(v);
    } catch (e){
      // TODO:
      // $.echo(β.red(`\t${v}`))
      return ' ' + v;
    }
  }

  function getD(_){
    return _.split('---@')[0].replace(/---/g, '').replace(/```([\s\S]+?```)/g, '```lua$1').trim();
  }

  function getF(_, g, s){
    let c = 0;
    _.replace(/---@param ([\w.]+) ((?:\S+|(?<=[:,]) )+)(?: (.+))?/g, (_, n, t, d) => {
      if (c++ == 0) g.push(`\n  Parameters:`);
      g.push(`\n${s}  ${c}. \`${n}\`: \`${t}\`${getPD(d)}`);
    });

    let r = 0, m = 0;
    _.replace(/---@return ([\w.|]+)(?: (.+))?/g, () => ++m);
    _.replace(/---@return ([\w.|]+)(?: (.+))?/g, (_, t, d) => {
      if (r++ == 0) g.push(`\n  Returns:`);
      g.push(`\n${s}  ${m > 1 ? r + '. ' : '- '}\`${t}\`${getPD(d)}`);
    });
  }

  content = content.replace(/\r/g, '');
  const p = content.split(/(?=--\[\[ [\w./]+ \]\])/);
  const t = {};
  const R = {};
  for (let i = 1; i < p.length; ++i){
    let j = p[i];
    let l = j.indexOf('\n');
    let f = j.substr(5, l - 8);
    const g = t[f] || (t[f] = []);
    j.substr(l + 1).replace(/(?:---.*\n)+(.+)/g, (_, l) => {
      const d = getD(_);

      if (/@class (\S+)/.test(_)){
        const cn = RegExp.$1;
        g.push(`## Class ${cn}`);
        if (d) g.push(d);
        if (/(\S+) = /.test(l)){
          R[RegExp.$1] = true;
          j.replace(new RegExp(`(?:---.*\\n)*function ${RegExp.$1}([:.]\\w+)(.*?) end`, 'g'), (_, t, a) => {
            g.push(`\n- \`${cn}${t}${a}\``);
            const d = getD(_);
            if (d) g.push(`\n  ${d}`);
            getF(_, g, '  ');
          });
        } else {
          // TODO:
          // $.echo(β.red(`\t${l}`));
        }
      } else if (/function ([\w.]+)(.+) end/.test(l) && !R[RegExp.$1.split('.')[0]]) {
        const fn = RegExp.$1;
        g.push(`## Function ${fn}${RegExp.$2}`);
        if (d) g.push(d);
        getF(_, g, '');
      }
    });
  }
  return `# Library ${module}

Documentation for ${module}. Please note: documentation generator is in development and needs more work, so some information might be missing and other bits might not be fully accurate.

` + Object.entries(t).map(x => `# Module ${x[0]}\n\n${x[1].join('\n')}`).join('\n\n');
}

function saveLDocLib(dir, content){  
  const finalized = finalizeLDoc(content, path.basename(dir));
  verifyLDocIntegrity(finalized);
  $.mkdir('-p', dir);
  // $.rm(`${dir}/*.lua`);
  fs.writeFileSync(`${dir}/lib.lua`, finalized);
  fs.writeFileSync(`${dir}/README.md`, generateLDocMd(finalized, path.basename(dir)));

  /* const p = content.split(/(?=--\[\[ [\w.]+ \]\])/);
  fs.writeFileSync(`${dir}/lib.lua`, p[0]);

  const t = {};
  for (let i = 1; i < p.length; ++i){
    let j = p[i];
    let l = j.indexOf('\n');
    let f = j.substr(5, l - 8).replace(/^\w+\.(?!lua)/, '');
    (t[f] || (t[f] = [])).push(j);
  }

  for (let n in t){    
    fs.writeFileSync(`${dir}/${n}`, t[n].join('\n\n'));
  } */
}

function finalizeCDefs(code){
  const ffi = [];
  code = code.replace(/\r/g, '');
  code = code.replace(/\bffi\.cdef "([\s\S]+?)"\n/g, (_, c) => {
    ffi.push(c);
    return '';
  });

  const ffiStr = ffi.join('');
  const ffiStatements = [];

  let b = 0;
  let s = '';
  for (let i = 0; i < ffiStr.length; ++i){
    const c = ffiStr[i];
    s = s + c;
    if (c == '{') ++b;
    if (c == '}') --b;
    if (c == ';' && !b) { ffiStatements.push(s); s = ''; }
  }

  for (let i = 1; i < ffiStatements.length; ++i){
    if (ffiStatements[i].startsWith('typedef')){
      if (!/ (\w+);$/.test(ffiStatements[i])) $.fail(`Unexpected typedef: ${ffiStatements[i]}`);
      const s = RegExp.$1;
      for (let j = 0; j < i; ++j){
        if (new RegExp(`\\b${s}\\b`).test(ffiStatements[j])){
          $.echo(β.red(`\tWrong FFI order: ${s} is mentioned before its definition in ${ffiStatements[j]}`));
        }
      }
    }
  }

  // code = `ffi.cdef [[${ffiStatements.join('\n')}]]
  code = `ffi.cdef "${ffiStatements.join('').replace(/\} /g, '}')}"
local _FC = ffi.C
${code.replace(/\bffi\.C\./g, '_FC.').replace(/(?<!function )\b__util\.str(?=\()/g, '__ust')}`;

  const locals = {};
  code = code.replace(/\nlocal(?: function)? (\w+)(?: = .+)?/g, (_, n) => { 
    if (locals[n]) {
      if (locals[n] == _) return '';
      $.fail(`redefined: ${n}`); 
    }
    locals[n] = _;

    if (!new RegExp('(?<!local |local function )\\b' + n + '\\b').test(code)){
      if (!/^__u(?:c[fe]|s[ofs]|t.+)$/.test(n)) $.echo(β.grey(`\tRemoving unused: ${n}`))
      return '';
    }
    return _;
  });

  return code;
}

function consumeSpecial(_, i, g){ 
  const c = _[i]; 
  if (c == '\'' && g != c) do { i = consumeSpecial(_, i + 1, '\'') } while(_[i] && _[i] != '\'');
  else if (c == '"' && g != c) do { i = consumeSpecial(_, i + 1, '"') } while(_[i] && _[i] != '"');
  else if (c == '{') do { i = consumeSpecial(_, i + 1) } while(_[i] && _[i] != '}');
  else if (c == '(') do { i = consumeSpecial(_, i + 1) } while(_[i] && _[i] != ')');
  else if (c == '<') do { i = consumeSpecial(_, i + 1) } while(_[i] && _[i] != '>');
  else return i;
  return i + 1;
}

function verifyIntegrity(code){
  if (/\bscript\.(\w+)/.test(code)){
    $.echo(β.red(`\tWrongly defined script function: ${RegExp.$1}`));
  }
  
  code.replace(/\b(?<!ac\.)error\(.+/g, _ => {
    for (let i = 6; i < _.length; ++i){
      i = consumeSpecial(_, i);
      if (_[i] == ')') {
        if (!/,\s*\d+$/.test(_.substr(6, i - 6))){
          $.echo(β.red('\tError throws onto itself: ' + _))
        }
        return;
      }
    }
    $.echo(β.red('misparsed: ' + _));
  });
  
  code.replace(/[^\.]\berror(?!\().*/g, _ => {
    $.echo(β.red('incorrect use of keyword “error” (in library code): ' + _));
  });
}

const luaJit = $[process.env['LUA_JIT']];

async function precompileLua(name, script) {
  fs.writeFileSync(`.out/${name}.lua`, script);
  await luaJit('-bgn', name, `${name}.lua`, `${name}.raw`, { cwd: '.out' });
  return fs.readFileSync(`.out/${name}.raw`);
}

function processTarget(filename) {
  $.echo(`Processing Lua: ${filename}`);
  const ast = resolveRequires($.readText(filename), filename);
  const code = luamax.maxify(ast);
  code.replace(/ffi\.C\.(\w+)/g, (_, f) => knownTypes.referencedFunctions[f] = true);
  code.replace(/ffi\.typeof\(['"](?!struct)(\w+)/g, (_, f) => knownTypes.referencedTypes[f] = true);
  if (path.basename(filename) != 'ac_common.lua' && !/script = \{\}/.test(code)) $.echo(β.red(`  Missing “script” description`));
  checkTypes();
  const finalized = finalizeCDefs(code);
  verifyIntegrity(finalized);
  return finalized;
}

const version = (await luaJit('-v', { output: true })).split('--')[0].trim();
const description = `Lua libraries for AC CSP, precompiled with ${version} to speed up Lua initialization. All source code is available here:
<https://github.com/ac-custom-shaders-patch/acc-lua-sdk>

File “ini_std” is from a different INIpp project, used for expressions when parsing INIpp files:
<https://github.com/ac-custom-shaders-patch/inipp>

However if you’re intending on using those libraries in your own scripts, there are separate definitions with documentation available in EmmyLua format. Check out “extension/internal/lua-libs”. Or, better yet, if you're using Visual Studio Code, there is also a small extension which would automatically detect a library your project would need based on its workspace directories and put it in Lua extension config. With it, and, of course, with great Lua extension by sumneko, VS Code will show you available functions, methods, parameters, all with corresponding documentation, and even highlight possible mistakes.
`.wrap(100);

const packedPieces = [];
packedPieces.push({ key: 'readme.txt', data: description });

if (process.env['INI_STD_BINARY']) {
  packedPieces.push({ key: 'ini_std', data: fs.readFileSync(process.env['INI_STD_BINARY']) });
}

async function compile(filename) {
  const name = path.basename(filename, '.lua');
  packedPieces.push({ key: name, data: await precompileLua(name, processTarget(filename)) });
}

await compile('./ac_common.lua');
for (let filename of $.glob(`./tests/t*.lua`)) {
  fs.writeFileSync('./tests/_out.lua', jsMacroEngine($.readText('./tests/_core.lua') + '\n\n' + $.readText(filename), { test: true }))
  $.echo(`Running test: ${filename}`)
  const s = Date.now();
  await luaJit('-epackage.path = package.path .. ";?.lua"', './tests/_out.lua', { cwd: '.' });
  $.echo(β.grey(`\tTime taken: ${Date.now() - s} ms`));
}

let filter = process.argv.filter(x => x.startsWith('--skip=')).map(x => x.substr(`--skip=`.length));
for (let filename of $.glob(`./ac_*.lua`)) {
// for (let filename of $.glob(`./ac_car_*.lua`)) {
// for (let filename of $.glob(`./ac_apps*.lua`)) {
  if (filename === './ac_common.lua' || filename == './ac_tfx.lua') continue;
  if (filter.some(x => filename.indexOf(x) !== -1)) continue;
  await compile(filename);
}

const destination = path.resolve(`${process.env['LUA_OUTPUT']}/../lua.zip`);
$.echo(`Packed to ${destination}`)
await $.zip(packedPieces, { to: destination, comment: description.replace(/[“”’]/g, '\'') });
