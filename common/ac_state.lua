__source 'lua/api_state_provider.cpp'
__states 'lua/api_state_provider.cpp'

do
  local function _ptri(v, i)
    if v[i] ~= nil then return i + 1, v[i] end
  end

  ac.iterateCars = setmetatable({
    ordered = function ()
      return _ptri, ffi.C.lj_getCars_inner(1), 0
    end,
    leaderboard = function ()
      return _ptri, ffi.C.lj_getCars_inner(2), 0
    end,
    serverSlot = function ()
      -- for compatibility, there was a typo
      return _ptri, ffi.C.lj_getCars_inner(3), 0
    end,
    serverSlots = function ()
      return _ptri, ffi.C.lj_getCars_inner(3), 0
    end,
  }, {
    __call = function(_)
      return _ptri, ffi.C.lj_getCars_inner(0), 0
    end
  })

  local _cc = {}
  ac.getCar = setmetatable({
    ordered = function (index)
      return __util.secure_state(ffi.C.lj_getCar_innerord(1, tonumber(index) or 0))
    end,
    leaderboard = function (index)
      return __util.secure_state(ffi.C.lj_getCar_innerord(2, tonumber(index) or 0))
    end,
    serverSlot = function (index)
      return __util.secure_state(ffi.C.lj_getCar_innerord(3, tonumber(index) or 0))
    end,
    serverSlots = function (index)
      -- for compatibility, there was a typo
      return __util.secure_state(ffi.C.lj_getCar_innerord(3, tonumber(index) or 0))
    end,
  }, {
    __call = function(_, index)
    local k = tonumber(index) or 0
    local r = _cc[k]
    if not r then
      r = __util.secure_state(ffi.C.lj_getCar_inner(k))
      _cc[k] = r
    end
    return r
  end
  })
end

---@class ac.StateCar
ffi.metatype('state_car', { __index = {
  ---@return string
  skin = function (s) return ac.getCarSkinID(s.index) end,

  ---@return string
  tyresName = function (s) return ac.getTyresName(s.index) end,

  ---@return string
  tyresLongName = function (s) return ac.getTyresLongName(s.index) end,

  ---@return string
  id = function (s) return ac.getCarID(s.index) end,

  ---@return string
  name = function (s) return ac.getCarName(s.index) end,

  ---@return string
  brand = function (s) return ac.getCarBrand(s.index) end,

  ---@return string
  country = function (s) return ac.getCarCountry(s.index) end,

  ---@return string
  driverName = function (s) return ac.getDriverName(s.index) end,

  ---@return string
  driverNationCode = function (s) return ac.getDriverNationCode(s.index) end,

  ---@return string
  driverNationality = function (s) return ac.getDriverNationality(s.index) end,

  ---@return string
  driverTeam = function (s) return ac.getDriverTeam(s.index) end,

  ---@return string
  driverNumber = function (s) return ac.getDriverNumber(s.index) end,
} })