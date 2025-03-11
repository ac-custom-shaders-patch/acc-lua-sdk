__source 'extensions/graphics_adjustments/pp_filters.cpp'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_particles'
require './common/ac_extras_binaryinput'
require './wfx_impl/ac_postprocessing'

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@field update fun(dt: number) @Called each frame to apply post-processing. Make sure to at least draw main frame here with `ui.drawImage('dynamic::screen', vec2(), ui.windowSize())`. Param `dt` is time since the last call of `.update()` in seconds.
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Set fixed FOV for the whole of AC, overriding any FOV correction set by something like triple camera.
---@param fov number? @Pass `nil` to disable override.
function ac.setFixedFOV(fov) end

--[[) ?]]
