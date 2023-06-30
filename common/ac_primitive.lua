ffi.cdef [[
  typedef struct { float x, y; } vec2;
  typedef struct { float x, y, z; } vec3;
  typedef struct { float x, y, z, w; } vec4;
  typedef struct { float r, g, b; } rgb;
  typedef struct { float h, s, v; } hsv;
  typedef struct { union { struct { float r, g, b; }; struct { rgb rgb; }; }; float mult; } rgbm;
  typedef struct { float x, y, z, w; } quat;
]]

--[[? if (!ctx.ldoc) for (let TYPE of ['vec2', 'vec3', 'vec4', 'rgb', 'hsv', 'rgbm', 'quat']) { 

function buildMetaTable(T, INDEX_TABLE){
  if (/__tostring/.test(INDEX_TABLE) && /__call/.test(INDEX_TABLE)) return INDEX_TABLE;

  const dims = +T[3];
  const F = ['x', 'y', 'z', 'w'].slice(0, dims);
  const M = (s, j) => F.map(x => s.replace(/\$/g, x)).join(j || ', ');
  const C = s => T + '(' + F.map(x => s.replace(/\$/g, x)) + ')';
  const I = s => `ffi.istype(ct${T}, ${s})`;
  const O = s => `function(v, u) return type(v) == 'number' and ${C(`v${s}u.$`)} or ${I('u')} and ${C(`v.$${s}u.$`)} or ${C(`v.$${s}u`)} end`;

  return `{
  __call = function(_, ${F}) return ct${T}(${M('$ or 0')}) end,
  __tostring = function(v) return string.format('(${M('%s')})', ${M('v.$')}) end,
  __add = ${O('+')},
  __sub = ${O('-')},
  __mul = ${O('*')},
  __div = ${O('/')},
  __pow = ${O('^')},
  __unm = function(v) return ${C('-v.$')} end,
  __len = function(v) return v:length() end,
  __eq = function(v, o) return ${I('v')} and ${I('o')} and ${M('v.$ == o.$', ' and ')} end,
  __lt = function(v, o) return ${I('v')} and ${I('o')} and ${M('v.$ < o.$', ' and ')} end,
  __le = function(v, o) return ${I('v')} and ${I('o')} and ${M('v.$ <= o.$', ' and ')} end,
  __index = ${INDEX_TABLE}
}`;
}

const src = ('' + fs.readFileSync('common/ac_primitive_' + TYPE + '.lua')).split(';--[[]' + ']_G()').map(x => x.trim()); 
// out(TYPE + ' = nil\ndo ');
out('do ');
out(src[0] + '\n');
out(TYPE + ' = ffi.metatype(ct' + TYPE + ', ' + buildMetaTable(TYPE, src[1].replace()) + ')\n');
out(src[2] + ' end\n'); } ?]]

smoothing = require './ac_smoothing'
