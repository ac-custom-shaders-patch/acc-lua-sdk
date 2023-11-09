__source 'lua/api_common_debug.cpp'

local function _logstring(v)
  local t = type(v)
  if t == 'table' and not getmetatable(v) then
    return stringify(v)
  end
  if t == 'nil' then
    return '<nil>'
  end
  if v == '' then
    return '<empty>'
  end
  return tostring(v)
end

function ac.debug(key, value, a1, a2, a3, a4) 
  key = _logstring(key)
  local t = type(value)
  if t == 'number' then
    ffi.C.lj_debug_inner_num(key, value, tonumber(a1) or math.huge, tonumber(a2) or math.huge, tonumber(a3) or 0, tonumber(a4) or 0)
  elseif t == 'boolean' then
    ffi.C.lj_debug_inner_bool(key, value)
  elseif t == 'cdata' then
    if vec2.isvec2(value) then
      ffi.C.lj_debug_inner_vec2(key, value)
    elseif vec3.isvec3(value) then
      ffi.C.lj_debug_inner_vec3(key, value)
    elseif vec4.isvec4(value) then
      ffi.C.lj_debug_inner_vec4(key, value)
    elseif rgb.isrgb(value) then
      ffi.C.lj_debug_inner_rgb(key, value)
    elseif rgbm.isrgbm(value) then
      ffi.C.lj_debug_inner_rgbm(key, value)
    elseif value == nil then
      ffi.C.lj_debug_inner_str(key, nil)
    else
      ffi.C.lj_debug_inner_str(key, tostring(value))
    end
  elseif t == 'table' and not getmetatable(value) then
    ffi.C.lj_debug_inner_str(key, stringify(value))
  else
    ffi.C.lj_debug_inner_str(key, value ~= nil and tostring(value) or nil)
  end
end

---Prints a message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.log(...)
  local n, s = select('#', ...), ''
  for i = 1, n do
    s = i > 1 and s..', '.._logstring(select(i, ...)) or _logstring(select(i, ...))
  end
  ffi.C.lj_log_inner(s)
end

---Prints a warning message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.warn(...)
  local n, s = select('#', ...), ''
  for i = 1, n do
    s = i > 1 and s..', '.._logstring(select(i, ...)) or _logstring(select(i, ...))
  end
  ffi.C.lj_warn_inner(s)
end

---Prints an error message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.error(...)
  local n, s = select('#', ...), ''
  for i = 1, n do
    s = i > 1 and s..', '.._logstring(select(i, ...)) or _logstring(select(i, ...))
  end
  ffi.C.lj_error_inner(s)
end