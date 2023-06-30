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

typedef struct {
  int type;
  int size;
  union {
    const char* str;
    void* ptr;
    double value;
  };
} lua_snb_value;

typedef const lua_snb_value* lua_snb_data;
]]

do

local _t_cchar = ffi.typeof('char*')
local _t_blobview = ffi.typeof('blob_view')
local _t_snb = ffi.typeof('lua_snb_value')
local _lastb = {}

function __util.blob(data)
  if type(data) ~= 'string' then
    if not data then return nil end
    if type(data) == 'cdata' then
      local b = _t_blobview()
      b.p_begin = ffi.cast(_t_cchar, data)
      b.p_end = b.p_begin + ffi.sizeof(data)
      return b
    end
    data = tostring(data)
  end
  if _lastb.input == data then return _lastb.blob end 
  local b = _t_blobview()
  b.p_begin = data
  b.p_end = b.p_begin + #data
  _lastb.input, _lastb.blob = data, b
  return b
end

local _prs

function __util.prs()
  if not _prs then
    _prs = require 'internal.serialize'
  end
  return _prs
end

function __util.snb(data)
  local r = _t_snb()
  local tdata = type(data)
  if tdata == 'number' then
    r.type = 3
    r.value = data
  elseif tdata == 'boolean' then
    r.type = data and 4 or 5
  elseif tdata == 'string' then
    r.type = 1
    r.size = #data
    r.str = data
  elseif tdata == 'table' or tdata == 'cdata' then
    r.type = 2
    r.ptr = __util.prs().pack(data)
    -- data = stringify(data, true)
    -- r.size = #data
  else
    return nil
  end
  return r
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

function __util.strrefr(ref)
  return ffi.string(ref.p2 >= 0x10 and ref.buf or ref.ins, ref.p1)
end

function __util.strrefp(value)
  if value == nil then return nil end
  return __util.strrefr(value[0])
end

local __mtstrcref = {
  __index = {
    get = function(self, value)
      if value == nil then return nil end
      local r = self.ptr and value[0] or value
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

function __util.strcrefp()
  return setmetatable({ cache = {}, ptr = true }, __mtstrcref)
end

function __util.strcrefr()
  return setmetatable({ cache = {}, ptr = false }, __mtstrcref)
end

function __util.str(value)
  return value ~= nil and tostring(value) or ''
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
  if vec2.isvec2(arg) then return arg end
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
  if vec3.isvec3(arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if rgb.isrgb(arg) then
      ret.x = arg.r
      ret.y = arg.g
      ret.z = arg.b
    elseif rgbm.isrgbm(arg) then
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
  if vec4.isvec4(arg) then return arg end
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
  if rgb.isrgb(arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if rgbm.isrgbm(arg) then
      ret.r = arg.r * arg.mult
      ret.g = arg.g * arg.mult
      ret.b = arg.b * arg.mult
    elseif vec3.isvec3(arg) then
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
  if rgbm.isrgbm(arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    if rgb.isrgb(arg) then
      ret.r = arg.r
      ret.g = arg.g
      ret.b = arg.b
      ret.mult = 1
    elseif vec3.isvec3(arg) then
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
  if mat3x3.ismat3x3(arg) then return arg end
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
  if mat4x4.ismat4x4(arg) then return arg end
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
  return mat4x4.ismat4x4(arg) and arg or __u_def_mat4x4
end

function __util.num_or(v, f)
  if type(v) ~= 'number' then return f end
  return v
end

function __util.secure_refbool(arg, def)
  if refbool.isrefbool(arg) then return arg end
  if def == nil then return nil end
  def.value = arg and true or false
  return def
end

function __util.secure_refnumber(arg, def)
  if refnumber.isrefnumber(arg) then return arg end
  if def == nil then return nil end
  def.value = arg and true or false
  return def
end

local __u_def_vec2 = vec2()
function __util.ensure_vec2(arg)
  return vec2.isvec2(arg) and arg or __u_def_vec2
end

local __u_def_vec3 = vec3()
function __util.ensure_vec3(arg)
  return vec3.isvec3(arg) and arg or __u_def_vec3
end

local __u_def_vec4 = vec4()
function __util.ensure_vec4(arg)
  return vec4.isvec4(arg) and arg or __u_def_vec4
end

local __u_def_rgb = rgb()
function __util.ensure_rgb(arg)
  return rgb.isrgb(arg) and arg or __u_def_rgb
end

local __u_def_rgbm = rgbm()
function __util.ensure_rgbm(arg)
  return rgbm.isrgbm(arg) and arg or __u_def_rgbm
end

function __util.ensure_vec2_nil(arg)
  return vec2.isvec2(arg) and arg or nil
end

function __util.ensure_vec3_nil(arg)
  return vec3.isvec3(arg) and arg or nil
end

function __util.ensure_vec4_nil(arg)
  return vec4.isvec4(arg) and arg or nil
end

function __util.ensure_rgb_nil(arg)
  return rgb.isrgb(arg) and arg or nil
end

function __util.ensure_rgbm_nil(arg)
  return rgbm.isrgbm(arg) and arg or nil
end

local tb = debug.traceback

function __util.cbCall(fn, ...)
  local s, err = xpcall(fn, tb, ...)
  if not s then
    if worker then
      worker.__error = tostring(err)
    end
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

local _timeoutsN = 0
local __callbackListeners = {}
function __util.expectImmediateReply(callback)
  if not callback then return 0 end
  local replyID = __lastReplyID + 1
  __lastReplyID = replyID
  table.insert(__callbackListeners, { replyID = replyID, callback = callback })
  return replyID
end

local __setCallbacks, __setCallbacksEmpty = {}, nil
function __util.setCallback(callback)
  if type(callback) ~= 'function' then error('Callback should be a function', 3) end
  local replyID
  if __setCallbacksEmpty and #__setCallbacksEmpty > 0 then
    replyID = __setCallbacksEmpty[#__setCallbacksEmpty]
    table.remove(__setCallbacksEmpty, #__setCallbacksEmpty)
  else
    replyID = #__setCallbacks + 1
  end
  __setCallbacks[replyID] = callback
  return replyID
end
function __script.processCallback(replyID, ...)
  local cb = __setCallbacks[replyID]
  if cb then return cb(...) end
end
function __script.forgetCallback(replyID)
  if replyID == #__setCallbacks then
    table.remove(__setCallbacks, replyID)
  else
    if not __setCallbacksEmpty then
      __setCallbacksEmpty = {replyID}
    else
      __setCallbacksEmpty[#__setCallbacksEmpty + 1] = replyID
    end
    __setCallbacks[replyID] = false
  end
end

function __util.awaitingCallback()
  return __util.timersLeft() > 0 or next(__replyListeners) ~= nil
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
local __escapeMapInv = { [34] = '"', [39] = '\'', [47] = '/', [92] = '\\', [98] = '\8', [102] = '\12', [110] = '\n', [114] = '\13', [116] = '\9' }

local function __escapeChar(c)
  return __escapeMap[c] or string.format('\\u%04x', string.byte(c))
end

local function __nextNonWhitespace(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if b ~= 9 and b ~= 10 and b ~= 13 and b ~= 32 then return j end
  end
end

local function __nextDelimiter(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if not b or b == 9 or b == 10 or b == 13 or b == 32 or b == 44 or b == 93 or b == 125 then return j end
  end
end

local function __skip(str, i, commas)
  local o = string.byte(str, i)
  while o == 47 or commas and o == 44 do
    if o == 44 then
      i = __nextNonWhitespace(str, i + 1)
    elseif string.byte(str, i + 1) == 47 then
      for j = i + 2, #str do
        if string.byte(str, j) == 10 or string.byte(str, j) == 13 then
          i = __nextNonWhitespace(str, j + 1)
          break
        end
      end
    elseif string.byte(str, i + 1) == 42 then
      for j = i + 2, #str do
        if string.byte(str, j) == 42 and string.byte(str, j + 1) == 47 then
          i = __nextNonWhitespace(str, j + 2)
          break
        end
      end
    else
      return #str + 1, nil
    end
    o = string.byte(str, i)
  end
  return i, o
end

local function __endOfKey(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if not b or b == 58 then return str:sub(i - 1, j - 1):trim(), j + 1 end
    if b == 47 and (string.byte(str, j + 1) == 47 or string.byte(str, j + 1) == 42) then
      local k = str:sub(i - 1, j - 1):trim()
      return k, __skip(str, j) + 1
    end
  end
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

local function __jsonParse(str, i)
  local o
  i, o = __skip(str, i)
  if o == 34 or o == 39 then
    local res, j, k = '', i + 1, i + 1
    while true do
      local x = string.byte(str, j)
      if not x or x == o then
        return res..str:sub(k, j - 1), j + 1
      elseif x == 92 then
        res, j = res..str:sub(k, j - 1), j + 1
        local c = string.byte(str, j)
        if c == 117 then
          local hex = str:match('^[dD][89aAbB]%x%x\\u%x%x%x%x', j + 1) or str:match('^%x%x%x%x', j + 1) or ''
          local n1, n2 = tonumber(hex:sub(1, 4), 16), tonumber(hex:sub(7, 10), 16)
          res, j = res..(n2 and (string.codePointToUTF8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000))
            or n1 and string.codePointToUTF8(n1) or ''), j + #hex
        else
          res = res..(__escapeMapInv[c] or '')
        end
        k = j + 1
      end
      j = j + 1
    end
  elseif o == 116 then
    if str:sub(i, i + 3) == 'true' then return true, i + 5 end
    return nil, __nextDelimiter(str, i)
  elseif o == 102 then
    if str:sub(i, i + 4) == 'false' then return false, i + 6 end
    return nil, __nextDelimiter(str, i)
  elseif o == 110 then
    if str:sub(i, i + 3) == 'null' then return nil, i + 5 end
    return nil, __nextDelimiter(str, i)
  elseif o >= 48 and o <= 57 or o == 45 then
    local x = __nextDelimiter(str, i)
    return tonumber(str:sub(i, x - 1)), x
  elseif o == 91 or o == 123 then
    local res, key = {}, nil
    i = i + 1
    while i < #str do
      i = __nextNonWhitespace(str, i)
      i = __skip(str, i, true)
      if string.byte(str, i) == 93 or string.byte(str, i) == 125 then return res, i + 1 end
      if o == 91 then
        res[#res + 1], i = __jsonParse(str, i)
      elseif o == 123 then
        if string.byte(str, i) == 34 or string.byte(str, i) == 39 then
          key, i = __jsonParse(str, i)
          i = __nextNonWhitespace(str, i)
          i = __skip(str, i)
          if string.byte(str, i) == 58 then i = i + 1 end
        else
          key, i = __endOfKey(str, i + 1)
        end
        res[tostring(key)], i = __jsonParse(str, __nextNonWhitespace(str, i))
      end
    end
    return res, #str + 1
  else
    return nil, #str + 1
  end
end

function __util.jsonParse(str)
  if str == nil then return nil end
  str = tostring(str)
  local s, r = pcall(__jsonParse, str, __nextNonWhitespace(str, 1))
  if s then return r end
  return nil
end

end
