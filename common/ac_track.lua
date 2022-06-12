__source 'extensions/track_adjustments/track_scriptable_display.cpp'
__allow 'tsd'

-- access to track conditions
ffi.cdef [[ typedef struct { void* __data[4]; } trackcondition; ]]

---@param expression string @Expression similar to ones config have as CONDITION=… value.
---@param offset number? @Condition offset. Default value: 0.
---@param defaultValue number? @Default value in case referenced condition is missing or parsing failed. Default value: 0.
---@return ac.TrackCondition
function ac.TrackCondition(expression, offset, defaultValue)
  return ffi.gc(
    ffi.C.lj_trackcondition_new__tsd(__util.str(expression), tonumber(offset) or 0, tonumber(defaultValue) or 0),
    ffi.C.lj_trackcondition_gc__tsd)
end

---Track condition evaluator. Given expression, which might refer to some existing condition, condition input or a complex expression of those,
---computes the resulting value.
---@class ac.TrackCondition
ffi.metatype('trackcondition', { __index = {
  ---@return number
  get = function (s) return ffi.C.lj_trackcondition_get__tsd(s) end,
  ---@return rgb
  getColor = function (s) return ffi.C.lj_trackcondition_getcolor__tsd(s) end,
  ---@return boolean
  isDynamic = function (s) return ffi.C.lj_trackcondition_isdynamic__tsd(s) end,
} })

---Finds a car at a given place in a race, for creating leaderboards. Returns nil if couldn’t find a car.
---@param place integer @Starts with 1 for first place.
---@return ac.StateCar|nil
function ac.findCarAtPlace(place)
  for i = 0, ac.getSim().carsCount - 1 do  -- getCar() needs IDs from 0 to N-1
    local car = ac.getCar(i)
    if car.racePosition == place then return car end
  end
  return nil -- couldn’t find anything
end
