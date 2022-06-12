-- Helper module for internal use, please do not use it in your code. Mainly meant
-- for ensure types are correct when being passed to C++.

ffi.cdef[[
typedef struct {
  union {
    char ins[16];
    const char* buf;
  };
  uint64_t p1;
  uint64_t p2;
} lua_string_ref;

typedef struct {
  int key;
  int phase;
  lua_string_ref data;
  uint64_t data_hash;
} lua_string_cached_ref;

typedef struct {
  const char* p_begin;
  const char* p_end;
} blob_view;
]]

__util = {}

function __util.blob(data)
  if type(data) ~= 'string' then
    if not data then return nil end
    if type(data) == 'cdata' then
      local b = ffi.new('blob_view')
      b.p_begin = ffi.cast('const char*', data)
      b.p_end = b.p_begin + ffi.sizeof(data)
      return b
    end
    data = tostring(data)
  end
  local b = ffi.new('blob_view')
  b.p_begin = data
  b.p_end = b.p_begin + #data
  return b
end

function __util.disposable(key)
  if key == 0 then return function() end end
  return function() ffi.C.lj_unlink_inner(key) end
end

function __util.ffistrsafe(str, len)
  for i = 0, len do
    if str[i] == 0 then
      len = i
      break
    end
  end
  return ffi.string(str, len)
end

local _bxor = bit.bxor

function __util.ffistrhash(str, len)
  local h = 37
  for i = 0, len do
    if str[i] == 0 then break end
    h = _bxor(h * 54059, str[i] * 76963)
  end
  return h
end

function __util.secure_state(state)
  return state ~= nil and state or nil
end

function __util.strref_ref(ref)
  return ffi.string(ref.p2 >= 0x10 and ref.buf or ref.ins, ref.p1)
end

function __util.strref(value)
  if value == nil then return nil end
  local ref = value[0]
  return ffi.string(ref.p2 >= 0x10 and ref.buf or ref.ins, ref.p1)
end

local __mtstrcref = {
  __index = {
    get = function(self, value)
      if value == nil then return nil end
      local r = value[0]
      local c = self.cache[r.key]
      if c ~= nil and c.phase == r.phase then return c.str end
      local s = ffi.string(r.data.p2 >= 0x10 and r.data.buf or r.data.ins, r.data.p1)
      if c ~= nil then
        c.phase = r.phase
        c.str = s
      else
        self.cache[r.key] = { phase = r.phase, str = s }
      end
      return s
    end
  }
}

function __util.strcref()
  return setmetatable({ cache = {} }, __mtstrcref)
end

function __util.str(value)
  return value ~= nil and tostring(value) or ""
end

function __util.str_opt(value)
  if value ~= nil then return tostring(value) end
  return nil
end

function __util.cast_enum(value, min, max, def)
  if value == nil then return def end
  local i = math.floor(tonumber(value) or 0)
  -- if i < min or i > max then return def end
  if i < min then return def end
  return i
end

function __util.cast_vec2(ret, arg, def)
  if ffi.istype('vec2', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to vec2', 2)
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
  end
  return ret
end

function __util.cast_vec3(ret, arg, def)
  if ffi.istype('vec3', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if ffi.istype('rgb', arg) then
      ret.x = arg.r
      ret.y = arg.g
      ret.z = arg.b
    elseif ffi.istype('rgbm', arg) then
      ret.x = arg.r * arg.mult
      ret.y = arg.g * arg.mult
      ret.z = arg.b * arg.mult
    else
      error('Cannot convert '..tostring(arg)..' to vec3', 2)
    end
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
    ret.z = num
  end
  return ret
end

function __util.cast_vec4(ret, arg, def)
  if ffi.istype('vec4', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to vec4', 2)
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
    ret.z = num
    ret.w = num
  end
  return ret
end

function __util.cast_rgb(ret, arg, def)
  if ffi.istype('rgb', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if ffi.istype('rgbm', arg) then
      ret.r = arg.r * arg.mult
      ret.g = arg.g * arg.mult
      ret.b = arg.b * arg.mult
    elseif ffi.istype('vec3', arg) then
      ret.r = arg.x
      ret.g = arg.y
      ret.b = arg.z
    else
      error('Cannot convert '..tostring(arg)..' to rgb', 2)
    end
  else
    local num = tonumber(arg) or 0
    ret.r = num 
    ret.g = num
    ret.b = num
  end
  return ret
end

function __util.cast_rgbm(ret, arg, def)
  if ffi.istype('rgbm', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if ffi.istype('rgb', arg) then
      ret.r = arg.r
      ret.g = arg.g
      ret.b = arg.b
      ret.mult = 1
    elseif ffi.istype('vec3', arg) then
      ret.r = arg.x
      ret.g = arg.y
      ret.b = arg.z
      ret.mult = 1
    else
      error('Cannot convert '..tostring(arg)..' to rgbm', 2)
    end
  else
    local num = tonumber(arg) or 0
    ret.r = num 
    ret.g = num
    ret.b = num
    ret.mult = 1
  end
  return ret
end

function __util.cast_mat3x3(ret, arg, def)
  if ffi.istype('mat3x3', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to mat3x3', 2)
  else
    local num = tonumber(arg) or 0
    ret.row1:set(num, num, num)
    ret.row2:set(num, num, num)
    ret.row3:set(num, num, num)
  end
  return ret
end

function __util.cast_mat4x4(ret, arg, def)
  if ffi.istype('mat4x4', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to mat4x4', 2)
  else
    local num = tonumber(arg) or 0
    ret.row1:set(num, num, num)
    ret.row2:set(num, num, num)
    ret.row3:set(num, num, num)
    ret.row4:set(num, num, num)
  end
  return ret
end

local __u_def_mat4x4 = nil
function __util.ensure_mat4x4(arg)
  if __u_def_mat4x4 == nil then __u_def_mat4x4 = mat4x4() end
  return ffi.istype('mat4x4', arg) and arg or __u_def_mat4x4
end

function __util.num_or(v, f)
  if type(v) ~= 'number' then return f end
  return v
end

function __util.secure_refbool(arg, def)
  if ffi.istype('refbool', arg) then return arg end
  if def == nil then return nil end
  def.value = arg and true or false
  return def
end

function __util.secure_refnumber(arg, def)
  if ffi.istype('refnumber', arg) then return arg end
  if def == nil then return nil end
  def.value = arg and true or false
  return def
end

local __u_def_vec2 = vec2()
function __util.ensure_vec2(arg)
  return ffi.istype('vec2', arg) and arg or __u_def_vec2
end

local __u_def_vec3 = vec3()
function __util.ensure_vec3(arg)
  return ffi.istype('vec3', arg) and arg or __u_def_vec3
end

local __u_def_vec4 = vec4()
function __util.ensure_vec4(arg)
  return ffi.istype('vec4', arg) and arg or __u_def_vec4
end

local __u_def_rgb = rgb()
function __util.ensure_rgb(arg)
  return ffi.istype('rgb', arg) and arg or __u_def_rgb
end

local __u_def_rgbm = rgbm()
function __util.ensure_rgbm(arg)
  return ffi.istype('rgbm', arg) and arg or __u_def_rgbm
end

function __util.ensure_vec2_nil(arg)
  return ffi.istype('vec2', arg) and arg or nil
end

function __util.ensure_vec3_nil(arg)
  return ffi.istype('vec3', arg) and arg or nil
end

function __util.ensure_vec4_nil(arg)
  return ffi.istype('vec4', arg) and arg or nil
end

function __util.ensure_rgb_nil(arg)
  return ffi.istype('rgb', arg) and arg or nil
end

function __util.ensure_rgbm_nil(arg)
  return ffi.istype('rgbm', arg) and arg or nil
end

local tb = debug.traceback

function __util.cbCall(fn, ...)
  local s, err = xpcall(fn, tb, ...)
  if not s then
    ac.error('Error in callback: '..tostring(err))
  end
end

-- a cheap way to get simple replies from asynchronous calls
local __lastReplyID = 0

local __replyListeners = {}
function __util.expectReply(callback)
  if not callback then return 0 end
  local replyID = __lastReplyID + 1
  __lastReplyID = replyID
  table.insert(__replyListeners, { replyID = replyID, callback = callback })
  return replyID
end
function __script.processReply(replyID, ...)
  for i = #__replyListeners, 1, -1 do
    local l = __replyListeners[i]
    if l.replyID == replyID then
      __util.cbCall(l.callback, ...)
      table.remove(__replyListeners, i)
      return
    end
  end
end

local __callbackListeners = {}
local __callbackListenersAny = false
function __util.expectImmediateReply(callback)
  if not callback then return 0 end
  local replyID = __lastReplyID + 1
  __lastReplyID = replyID
  table.insert(__callbackListeners, { replyID = replyID, callback = callback })
  return replyID
end
function __script.processImmediateReply(replyID, ...)
  for i = #__callbackListeners, 1, -1 do
    local l = __callbackListeners[i]
    if l.replyID == replyID then
      __util.cbCall(l.callback, ...)
      table.remove(__callbackListeners, i)
    end
  end
end

local __setCallbacks = {}
function __util.setCallback(callback)
  if type(callback) ~= 'function' then error('Callback should be a function', 3) end
  local replyID = #__setCallbacks + 1
  __setCallbacks[replyID] = callback
  return replyID
end
function __script.processCallback(replyID, ...)
  local cb = __setCallbacks[replyID]
  if cb then return cb(...) end
end

function __util.updateInner(dt)
  if __callbackListenersAny then
    __callbackListenersAny = false
    __callbackListeners = {}
  end
end

local __toDispose, __toDisposeN = {}, 0
function __script.handleError()
  for i = __toDisposeN, 1, -1 do
    pcall(__toDispose[i])
  end
  __toDisposeN = 0
end

function __util.pushEnsureToCall(fn)
  local n = __toDisposeN + 1
  __toDispose[n], __toDisposeN = fn, n
end

function __util.popEnsureToCall(fn)
  local n = __toDisposeN
  if n > 0 then
    __toDispose[n]()
    __toDisposeN = n - 1
  end
end

-- Simple JSON encoder based on json.lua by rxi (but slightly streamlined) for easier passing of complex data
-- to FFI bindings. Whole idea is far from optimal, but calls that need complex data don’t usually need high
-- performance anyway.

local __escapeMap = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }

local function __escapeChar(c)
  return __escapeMap[c] or string.format('\\u%04x', string.byte(c))
end

function __util.json(v, s)
  local t = type(v)
  if t == 'table' then
    if not s then s = {[v] = true} elseif s[v] then return 'null' else s[v] = true end
    s, s[v] = table.isArray(v) 
      and '['..table.concat(table.map(v, function (i) return __util.json(i, s) end), ',')..']'
      or '{'..table.concat(table.map(v, function (i, k) return __util.json(tostring(k))..':'..__util.json(i, s) end), ',')..'}', nil
    return s
  end
  return (t == 'string' or t == 'cdata') and '"'..string.gsub(tostring(v), '[\1-\31\\"]', __escapeChar)..'"'
    or (t == 'boolean' or t == 'number' and v == v and v > -math.huge and v < math.huge) and tostring(v) or 'null'
end
