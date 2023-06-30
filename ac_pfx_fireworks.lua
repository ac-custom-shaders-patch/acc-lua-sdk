__source 'extensions/particles_fx/fireworks_lua.cpp'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_scene'
require './wfx_common/ac_weatherconditions'
require './pfx_fireworks/ac_fireworks'
require './pfx_fireworks/ac_lists'

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