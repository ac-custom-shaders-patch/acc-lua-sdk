__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__allow 'controller'

require './common/internal_import'
require './common/ac_extras_backgroundworker'
require './common/ac_extras_binaryinput'

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each frame.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

--[[) ?]]