ffi.cdef [[ 
typedef struct {
  uint64_t __key;
  rgbm color;
  bool friend;
  bool muted;
} socialdata;
]]

local _sdch = {}
local function _sdca(d, i)
  local e = _sdch[d]
  if not e then
    e = ffi.new('socialdata')
    _sdch[d] = e
  end
  ffi.C.lj_socialdata_sync(e, i, d)
  return e
end

local _sdmt = {
  __tostring = function (s)
    local t = {}
    if s.__d.friend then t[#t + 1] = 'friend' end
    if s.__d.friend then t[#t + 1] = 'muted' end
    return string.format('%s: [%s]', s.__n, table.concat(t, ', '))
  end,
  __index = function (s, key)
    ffi.C.lj_socialdata_sync(s.__d, s.__i, s.__n)
    if key == 'friend' then return s.__d.friend end
    if key == 'muted' then return s.__d.muted end
    if key == 'color' then return s.__d.color end
    return false
  end,
  __newindex = function (s, key, value)
    if key == 'friend' then 
      if s.__d.friend == not not value then return end 
      s.__d.friend = not s.__d.friend
    elseif key == 'muted' then 
      if s.__d.muted == not not value then return end 
      s.__d.muted = not s.__d.muted
    elseif key == 'color' then 
      if s.__d.color == value or not rgbm.isrgbm(value) then return end
      s.__d.color = value
      if ac.setDriverChatNameColor then ac.setDriverChatNameColor(s.__i, value) end
      return
    else return end
    ffi.C.lj_socialdata_upsync(s.__d, s.__n)
  end
}

---Faster way to deal with driver tags. Any request unsupported fields will return `false` for further extendability.
---Scripts with access to I/O can also alter fields.
---@class ac.DriverTags
---@field color rgbm @User name color.
---@field friend boolean @Friend tag, uses CSP and CM databases.
---@field muted boolean @Muted tag, if set messages in chat will be hidden.
---@constructor fun(driverName: string): ac.DriverTags

function ac.DriverTags(driverName)
  local i = ac.getCarByDriverName(driverName)
  return setmetatable({__n = driverName, __i = i, __d = _sdca(driverName, i)}, _sdmt)
end

---Checks if a user is tagged as a friend. Uses CSP and CM databases. Deprecated, use `ac.DriverTags` instead.
---@deprecated
---@param driverName string @Driver name.
---@return boolean
function ac.isTaggedAsFriend(driverName)
  return _sdca(driverName, -1).friend
end

---Tags user as a friend (or removes the tag if `false` is passed). Deprecated, use `ac.DriverTags` instead.
---@deprecated
---@param driverName string @Driver name.
---@param isFriend boolean? @Default value: `true`.
function ac.tagAsFriend(driverName, isFriend)
  local e = _sdca(driverName, -1)
  if e.friend == (isFriend ~= false) then return end
  e.friend = isFriend ~= false
  ffi.C.lj_socialdata_upsync(driverName, e)
end
