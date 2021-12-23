ffi.cdef [[ 
typedef struct {
  float ambient, road;
} weather_conditions_temperatures;

typedef struct {
  float sessionStart, sessionTransfer, randomness, lapGain;
} weather_conditions_track;

typedef struct {
  float direction, speedFrom, speedTo;
} weather_conditions_wind;

typedef struct {
  weather_type currentType;
  weather_type upcomingType;
  weather_conditions_temperatures temperatures;
  weather_conditions_track trackState;
  weather_conditions_wind wind;
  float transition;
  float humidity, pressure;
  float variableA, variableB, variableC;
  float rainIntensity, rainWetness, rainWater;
} weather_conditions;
]]

---State of the track surface.
---@class ac.TrackConditions
---@field sessionStart number @From 0 to 100.
---@field sessionTransfer number @From 0 to 100.
---@field randomness number
---@field lapGain number
ac.TrackConditions = ffi.metatype('weather_conditions_track', { __index = {} })

---@class ac.TemperatureParams
---@field ambient number @Temperature in C°.
---@field road number @Temperature in C°.
ac.TemperatureParams = ffi.metatype('weather_conditions_temperatures', { __index = {} })

---@class ac.WindParams
---@field direction number @Speed in km/h.
---@field speedFrom number @Speed in km/h.
---@field speedTo number @Speed in km/h.
ac.WindParams = ffi.metatype('weather_conditions_wind', { __index = {} })

---@class ac.ConditionsSet
---@field currentType ac.WeatherType
---@field upcomingType ac.WeatherType
---@field temperatures ac.TemperatureParams
---@field trackState ac.TrackConditions
---@field wind ac.WindParams
---@field transition number @From 0 to 1 (if you’re doing linear transition, better to apply `math.smoothstep()` function to this value).
---@field humidity number @From 0 to 1, 1 for 100% humidity.
---@field pressure number @Pressure In pascals.
---@field variableA number @Custom value for extra data to exchange between controller and implementation (please remember that controller can be swapped with a different one).
---@field variableB number @Custom value for extra data to exchange between controller and implementation (please remember that controller can be swapped with a different one).
---@field variableC number @Custom value for extra data to exchange between controller and implementation (please remember that controller can be swapped with a different one).
---@field rainIntensity number @From 0 to 1, 0.5 for a good heavy-ish rain, everything above is for more absurd thunderstorms.
---@field rainWetness number @From 0 to 1, quickly goes to 1 as rain starts pouring, quickly goes to 0 when rain stops.
---@field rainWater number @Amount of puddles, should slowly move towards rainIntensity value.
ac.ConditionsSet = ffi.metatype('weather_conditions', { __index = {} })
