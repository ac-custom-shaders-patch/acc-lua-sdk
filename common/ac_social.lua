ffi.cdef [[ 
typedef struct {
  uint64_t __key;
  rgbm color;
  bool friend;
  bool muted;
  uint8_t _pad;
  uint8_t _extraTags_count;
  uint8_t _extraTags_items[12];
} socialdata;
]]

local _sdch, _sddt, _sdet
local function _sdca(d, i)
  if not _sdch then _sdch = {} end
  local e = _sdch[d]
  if not e then
    if not _t_socialdata then
      _t_socialdata = ffi.typeof('socialdata')
    end
    e = _t_socialdata()
    _sdch[d] = e
  end
  ffi.C.lj_socialdata_sync(e, i, d)
  return e
end

local function _sdea(i)
  if not _sdet then
    _sdet = {}
  end
  local g = tonumber(i)
  if not _sdet[g] then
    local c = rgbm()
    local v = ffi.C.lj_socialdata_gettag(g, c)
    _sdet[g] = v and {name = __util.strrefp(v), color = c} or false
  end
  return _sdet[g] or nil
end

local function _sdip(s, i)
  i = i + 1
  if i <= #s then return i, s[i] end
end

local _sdmt = {
  __tostring = function (s)
    local t = {}
    if s.__d.friend then t[#t + 1] = 'friend' end
    if s.__d.muted then t[#t + 1] = 'muted' end
    return string.format('%s: [color=%s, %s]', s.__n, s.__d.color, table.concat(t, ', '))
  end,
  __len = function (s)
    return (s.__d.muted and 1 or 0) + (s.__d.friend and 1 or 0) + s.__d._extraTags_count
  end,
  __ipairs = function(s)
    return _sdip, s, 0
  end,
  __index = function (s, key)
    ffi.C.lj_socialdata_sync(s.__d, s.__i, s.__n)
    if key == 'friend' then return s.__d.friend end
    if key == 'muted' then return s.__d.muted end
    if key == 'color' then return s.__d.color end
    if type(key) == 'number' then
      if s.__d.muted then
        if key == 1 then return _sdea(-2) end
        key = key - 1
      end
      if s.__d.friend then
        if key == 1 then return _sdea(-1) end
        key = key - 1
      end
      if key > 0 and key <= s.__d._extraTags_count then
        return _sdea(s.__d._extraTags_items[key - 1])
      end
      return nil
    end
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

---Faster way to deal with driver tags. Any request of unsupported fields will return `false` for further extendability.
---Scripts with access to I/O can also alter fields.
---@class ac.DriverTags
---@field color rgbm @User name color. Could be derived from custom color set via `ac.DriverTags` (or `ac.setDriverChatNameColor()`), turns reddish if driver is muted, or uses custom driver tag from CM if any is set, or turns greenish if driver is marked as a friend (in CSP or CM). For the player entry it will always be yellow.
---@field friend boolean @Friend tag, uses CSP and CM databases.
---@field muted boolean @Muted tag, if set messages in chat will be hidden.
---@constructor fun(driverName: string): ac.DriverTags

function ac.DriverTags(driverName)
  if not _sddt then _sddt = {} end
  local r = _sddt[driverName]
  if not r then
    local i = ac.getCarByDriverName(driverName)
    r = setmetatable({__n = driverName, __i = i, __d = _sdca(driverName, i)}, _sdmt)
    _sddt[driverName] = r
  end
  return r
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
