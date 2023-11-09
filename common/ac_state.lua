__source 'lua/api_state_provider.cpp'
__states 'lua/api_state_provider.cpp'

do
  local function _ptri(v, i)
    if v[i] ~= nil then return i + 1, v[i] end
  end

  ac.iterateCars = setmetatable({
    ordered = function ()
      return _ptri, ffi.C.lj_getCars_inner(true), 0
    end,
  }, {
    __call = function(_)
      return _ptri, ffi.C.lj_getCars_inner(false), 0
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