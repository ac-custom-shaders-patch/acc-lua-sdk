__source 'extensions/particles_fx/fireworks_lua.cpp'

require './common/internal_import'
require './inc_scene'
require './pfx_fireworks/ac_fireworks'
require './pfx_fireworks/ac_lists'

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@field update fun(dt: number) @Called each frame. Param `dt` is time since the last call of `.update()` in seconds.
---@single-instance
script = {}
