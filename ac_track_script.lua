--[[? ctx.flags.withPhysics = true; ?]]
--[[? ctx.flags.withoutIO = true; ?]]

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_track'
require './common/ac_track_conditions'
require './common/ac_particles'
require './common/ac_physics'
require './common/ac_physics_ai'
require './common/ac_extras_binaryinput'
require './common/ac_extras_yebiscolorcorrection'
require './common/secure'

---Returns values from section which defined current script. Use `layout` to specify which
---values are needed, with their corresponding default values to determine types. This function
---can be used to configure script from config, allowing to create customizable scripts which
---would, for example, act as new types of displays, especially if used with INIpp templates.
---
---Note: consider using lowerCamelCase for keys to make sure there wouldn’t be a collision with
---CSP parameters for track scripts, as well as with INIpp template parameters (which use UpperCamelCase).
---
---You can achieve the same results by using `ac.getTrackConfig()` (name of section which creates script
---is available in `__cfgSection__` global variable). This is just a shortcut to make things nicer.
---@generic T
---@param layout T
---@return T
function ac.configValues(layout)
  return table.map(layout, function (item, index) return ac.getTrackConfig(__cfgSection__, index, item), index end)
end

-- automatically generated entries go here:
__definitions()

-- extra additions:

---Reference to information about state of player’s car. To access other cars, use `ac.getCar(N)` (N is for 0-based index).
---@type ac.StateCar
car = nil

---Reference to information about state of simulation.
---@type ac.StateSim
sim = nil

function __script.__init__()
  car = ac.getCar(0)
  sim = ac.getSim()
end

-- script format:
---@class ScriptData
---@field update fun(dt: number): number, number @For `[SCRIPTABLE_DISPLAY_...]` called when display updates. For `[SCRIPT_...]` called when sim updates. Param `dt` is time since the last call of `.update()` in seconds.
---@field draw3D fun() @Only for `[SCRIPT_...]`. Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here.
---@field frameBegin fun(dt: number, gameDT: number) @Only for `[SCRIPT_...]`. Called at the beginning of a frame, before all rendering starts. If you want to move things, `script.update()` might be a better option. This one is only if you’d find that `script.update()` happens a bit too early for you. Param `dt` is for how much time has passed since last call, in seconds. Param `gameDT` is for how much time has passed in simulation (slower with slow-mo replays, 0 when paused), in seconds.
---@field onReplayStart fun() @Only for `[SCRIPT_...]`. Called when replay starts. If you have any race-only things happening, like maybe a safe car animation, that would be the good time to hide them.
---@field onReplayStop fun() @Only for `[SCRIPT_...]`. Called when replay stops. If you have any race-only things happening, like maybe a safe car animation, that would be the good time to show them back (if you hid them in `script.onReplayStart()`).
---@single-instance
script = {}
