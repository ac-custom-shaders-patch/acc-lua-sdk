__source 'extensions/online_plus/online_scripts.cpp'

--[[? ctx.flags.withoutIO = true; ?]]
--[[? ctx.flags.withPhysics = true; ?]]

require './common/internal_import'
require './common/ac_audio'
require './common/ac_color_corrections'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_track'
require './common/ac_gameplay'
require './common/ac_gameplay_apps'
require './common/ac_gameplay_replaystream'
require './common/ac_car_control'
require './common/ac_car_control_physics'
require './common/ac_particles'
require './common/ac_physics'
require './common/ac_physics_ai'
require './common/ac_extras_binaryinput'
require './common/ac_extras_yebiscolorcorrection'
require './common/secure'

local function __getServerConfig(section, key, def)
  return __util.native('cfg', 65537, section, key, def)
end

---Reconnect to a different server (or, if `params` is not set or empty, same server).
---If any values in table are missing, current values will be used.
--[[@tableparam params {
  serverIP: string "IP of a new server",
  serverPort: integer "TCP port of a new server",
  serverHttpPort: integer "HTTP port of a new server",
  serverName: string "Server name to show during loading",
  serverPassword: string "Optional server password",
  carID: string "Optional car ID (name of car folder) if user needs to change car when reconnecting",
  trackID: string "Track ID (name of folder in “content/tracks”), optional, used for loading background",
  trackLayoutID: string "Track layout ID, optional, used for loading background"
}]]
function ac.reconnectTo(params)
  ffi.C.lj_reconnect_to(__util.json(params))
end

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
  return table.map(layout, function (item, index) return __getServerConfig(__cfgSection__, index, item), index end)
end

-- automatically generated entries go here:
__definitions()

-- extra additions:

ac.colorCorrections = __util.boundArray(ffi.typeof('void*'), ffi.C.lj_set_corrections)

---Adds a color correction to the list of active color corrections.
---@param item ac.ColorCorrectionBase
function ac.addColorCorrection(item) return ac.colorCorrections:pushWhereFits(item) end

---Removes a color correction from the list of active color corrections.
---@param item ac.ColorCorrectionBase
function ac.removeColorCorrection(item) return ac.colorCorrections:erase(item) end

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
---@field update fun(dt: number) @Called each frame. Param `dt` is time since the last call of `.update()` in seconds.
---@field draw3D fun() @Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here.
---@field drawUI fun() @Use it to add custom HUD elements online: messages, or, for example, new race flags (use `ui.drawRaceFlag(color)` for that).
---@field frameBegin fun(dt: number, gameDT: number) @Called at the beginning of a frame, before all rendering starts. If you want to move things, `script.update()` might be a better option. This one is only if you’d find that `script.update()` happens a bit too early for you. Param `dt` is for how much time has passed since last call, in seconds. Param `gameDT` is for how much time has passed in simulation (slower with slow-mo replays, 0 when paused), in seconds.
---@single-instance
script = {}
