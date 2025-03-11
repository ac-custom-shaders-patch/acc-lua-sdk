__source 'extensions/particles_fx/fireworks_lua.cpp'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_scene'
require './common/ac_ui'
require './common/ac_extras_binaryinput'
require './pfx_fireworks/ac_fireworks'
require './pfx_fireworks/ac_lists'

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@field update fun(dt: number) @Called each frame. Param `dt` is time since the last call of `.update()` in seconds.
---@single-instance
script = {}
