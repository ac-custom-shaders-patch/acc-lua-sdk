__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__allow 'controller'

require './common/internal_import'
require './wfx_common/ac_weatherconditions'

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