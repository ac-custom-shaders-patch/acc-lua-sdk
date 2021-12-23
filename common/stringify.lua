local function _stringifyFlatItem(obj)
  local t = type(obj)
  return t == 'table' or t == 'function' or t == 'thread' or t == 'userdata'
end

local function _stringifyFlatArray(obj, isArray, size)
  if isArray then
    for i = 1, size do
      if _stringifyFlatItem(obj[i]) then return false end
    end
  else
    for k, v in pairs(obj) do
      if _stringifyFlatItem(k) or _stringifyFlatItem(v) then return false end
    end
  end
  return true
end

local function _stringifyKey(out, ptr, obj, fnFullStringfy, lineBreak, depthLimit)
  local objType = type(obj)
  if objType == 'number' or objType == 'boolean' then
    out[ptr] = '['
    out[ptr + 1] = tostring(obj)
    out[ptr + 2] = ']'
    return ptr + 3
  end
  if objType == 'string' then
    out[ptr] = string.match(obj, '^[%a_][%w_]*$') and obj or string.format('[%q]', obj)
  else
    out[ptr] = '['
    ptr = fnFullStringfy(out, ptr + 1, obj, lineBreak, depthLimit)
    out[ptr] = ']'
  end
  return ptr + 1
end

local _svst, _svsp = nil, {}

local function _stringify(out, ptr, obj, lineBreak, depthLimit)
  local objType = type(obj)

  if objType == 'number' or objType == 'boolean' then
    out[ptr] = tostring(obj)
    return ptr + 1
  end

  if objType == 'string' then
    out[ptr] = string.format('%q', obj)
    return ptr + 1
  end

  if objType == 'table' then
    if not _svst then
      error('Invalid call', 2)
    end
    if _svst[obj] then
      out[ptr] = lineBreak and '{ type = "circular reference" }' or '{type="circular reference"}'
      return ptr + 1
    end
    if depthLimit < 0 then
      out[ptr] = lineBreak and '{ type = "depth limit reached" }' or '{type="depth limit reached"}'
      return ptr + 1
    end

    if type(obj.__stringify) == 'function' then
      _svst[obj] = true
      local r = obj:__stringify(out, ptr, lineBreak, depthLimit - 1)
      local q = type(r)
      if q == 'number' then
        ptr = r
      elseif type(r) == 'string' then
        out[ptr] = r
        ptr = ptr + 1
      else
        error('Method __stringify should either write string to provided table at a given position and return new position, or return a string', 2)
      end
      _svst[obj] = nil
      return ptr
    end

    if next(obj) == nil then
      out[ptr] = '{}'
      return ptr + 1
    end

    local isArray = table.isArray(obj)
    local size = #obj
    local isFlat = lineBreak and _stringifyFlatArray(obj, isArray, size)
    local comma, tabChild
    if not lineBreak then
      out[ptr], comma, tabChild = '{', ',', nil
    elseif isFlat then
      out[ptr], comma, tabChild = '{ ', ', ', lineBreak
    else
      tabChild = lineBreak .. '  '
      comma = ',' .. tabChild
      out[ptr] = '{'
      out[ptr + 1] = tabChild
      ptr = ptr + 1
    end

    _svst[obj] = true
    if isArray then
      for i = next(obj), size do
        ptr = _stringify(out, ptr + 1, obj[i], tabChild, depthLimit - 1)
        out[ptr] = comma
      end
    else
      local h = 0 -- largest key of array-style elements
      for i = obj[0] and 0 or 1, size do
        if obj[i] == nil then break end
        h = i
        ptr = _stringify(out, ptr + 1, obj[i], tabChild, depthLimit - 1)
        out[ptr] = comma
      end
      for k, v in pairs(obj) do
        if type(k) ~= 'number' or k > h then
          ptr = _stringifyKey(out, ptr + 1, k, _stringify, tabChild, depthLimit - 3)
          out[ptr] = lineBreak and ' = ' or '='
          ptr = _stringify(out, ptr + 1, v, tabChild, depthLimit - 1)
          out[ptr] = comma
        end
      end
    end
    -- _svst[obj] = nil
    out[ptr] = isFlat and ' }' or lineBreak and lineBreak..'}' or '}' -- replace last comma by }
    return ptr + 1
  end

  if objType == 'cdata' then
    local comma = lineBreak and ', ' or ','
--[[? for (let [type, fields] of [
      [ 'vec2', ['x', 'y'] ],
      [ 'vec3', ['x', 'y', 'z'] ],
      [ 'vec4', ['x', 'y', 'z', 'w'] ],
      [ 'quat', ['x', 'y', 'z', 'w'] ],
      [ 'rgb', ['r', 'g', 'b'] ],
      [ 'rgbm', ['r', 'g', 'b', 'mult'] ],
      [ 'hsv', ['h', 's', 'v'] ],
      [ 'refbool', ['value'] ],
      [ 'refnumber', ['value'] ],
    ]) out(`    if ${type}.is${type}(obj) then
      if ${fields.map(x => `obj.${x} == 0`).join(' and ')} then out[ptr] = '${type}()' return ptr + 1 end
      out[ptr] = '${type}('
${fields.map((x, i) => `      out[ptr + ${i * 2 + 1}] = tostring(obj.${x})\n      out[ptr + ${i * 2 + 2}] = ${i == fields.length - 1 ? `')'` : 'comma'}`).join('\n')}
      return ptr + ${fields.length * 2 + 1}
    end
`) ?]]    out[ptr] = lineBreak and '{ type = "cdata", tostring = ' or '{type="cdata",tostring='
    out[ptr + 1] = string.format('%q', tostring(obj))
    out[ptr + 2] = lineBreak and ' }' or '}'
    return ptr + 2
  end

  if objType == 'nil' then
    out[ptr] = 'nil'
    return ptr + 1
  end

  -- can’t really stringify these, but let’s at least give back something
  local fallback
  if objType == 'function' then
    local info = debug.getinfo(obj)
    fallback = string.format(lineBreak and '{ type = "function", name = %q, source = %q, what = %q }' or '{type="function",name=%q,source=%q,what=%q}', info.name, info.source, info.what)
  else
    fallback = string.format(lineBreak and '{ type = %q, tostring = %q }' or '{type=%q,tostring=%q}', objType, tostring(obj))
  end
  out[ptr] = fallback
  return ptr + 1
end

local _strt = nil
local _strp, _strn = {}, 0
local _penp, _penn = {}, 0
local _pent = {
  __index = function(_, k)
    local env = rawget(_, 'env')
    if env and env[k] then return env[k] end
    if _strt[k] then return _strt[k] end
    error('Not available: '..tostring(k), 2)
  end
}

local function _stringifyParse(v, env)
  if type(v) ~= 'string' then error('String is required', 2) end
  if not _strt then
    _strt = { vec2 = vec2, vec3 = vec3, vec4 = vec4, quat = quat, rgb = rgb, rgbm = rgbm, hsv = hsv, refbool = refbool, refnumber = refnumber }
  end
  local s = _penn
  local o = s > 0 and _penp[s] or setmetatable({ env = env }, _pent)
  if s > 0 then _penn, o.env = s - 1, env end
  local f, e = load('return '..v, 'stringify.parse', 't', o)
  if not f then error(e, 2) end
  local r = f()
  s = _penn + 1
  _penp[s], _penn = o, s
  return r
end

stringify = setmetatable({
  tryParse = function(v, env, fallback)
    local r, p = pcall(_stringifyParse, v, env)
    if r then return p end
    return fallback
  end,
  parse = _stringifyParse,
  register = function(n, v)
    if n.__name then _strt[n.__name] = n
    else _strt[n] = v end
  end,
  locals = function ()
    local variables = {}
    local idx = 1
    while true do
      local ln, lv = debug.getlocal(2, idx)
      if ln ~= nil then
        variables[ln] = lv
      else
        break
      end
      idx = 1 + idx
    end
    return variables
  end,
  substep = _stringify
}, {
  __call = function(_, v, compact, depthLimit)
    local q = _svst == nil
    if q then
      _svst = _svsp
    end
    local s = _strn
    local o = s > 0 and _strp[s] or {}
    if s > 0 then _strn = s - 1 end
    _stringify(o, 1, v, not compact and '\n' or nil, depthLimit or 20)
    local r = table.concat(o)
    s = _strn + 1
    _strp[s], _strn = o, s
    table.clear(o)
    if q then
      _svst = nil
      table.clear(_svsp)
    end
    return r
  end
})