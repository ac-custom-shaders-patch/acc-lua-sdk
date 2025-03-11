__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__allow 'controller'

require './common/internal_import'
require './common/ac_extras_backgroundworker'
require './common/ac_extras_binaryinput'

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@field update fun(dt: number) @Called each frame. Param `dt` is time since the last call of `.update()` in seconds.
---@single-instance
script = {}
