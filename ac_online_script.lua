__source 'extensions/online_plus/online_scripts.cpp'

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
require './common/ac_particles'
require './common/ac_physics'
require './common/secure'

ui.OnlineExtraFlags = __enum({ cpp = 'online_extra_flags' }, {
  None = 0,
  Admin = 1,  -- Feature will be available only to people signed up as admins with access to admin menu in that new chat app.
  Tool = 2    -- Instead of creating a modal popup blocking rest of UI, a tool would create a small window staying on screen continuously and be able to use rest of UI API there.
})

local function __getServerConfig(section, key, def)
  if type(def) == 'boolean' then return ffi.C.lj_cfg_server_bool(__util.str(section), __util.str(key), def) end
  if type(def) == 'number' then return ffi.C.lj_cfg_server_decimal(__util.str(section), __util.str(key), def) end
  if type(def) == 'string' then return __util.strref(ffi.C.lj_cfg_server_string(__util.str(section), __util.str(key), def)) end
  if rgb.isrgb(def) then return ffi.C.lj_cfg_server_rgb(__util.str(section), __util.str(key), def) end
  if rgbm.isrgbm(def) then return ffi.C.lj_cfg_server_rgbm(__util.str(section), __util.str(key), def) end
  if vec2.isvec2(def) then return ffi.C.lj_cfg_server_vec2(__util.str(section), __util.str(key), def) end
  if vec3.isvec3(def) then return ffi.C.lj_cfg_server_vec3(__util.str(section), __util.str(key), def) end
  if vec4.isvec4(def) then return ffi.C.lj_cfg_server_vec4(__util.str(section), __util.str(key), def) end
  if def == nil then error('Default value is required', 2) end
  error('Unknown type: '..type(def), 2)
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

ac.colorCorrections = __bound_array(ffi.typeof('void*'), ffi.C.lj_set_corrections)

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
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called when sim updates.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

---Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here.
function script.draw3D() end

---Use it to add custom HUD elements online: messages, or, for example, new race flags (use `ui.drawRaceFlag(color)` for that).
function script.drawUI() end

---Called at the beginning of a frame, before all rendering starts. If you want to move things, `script.update()` might be a better option.
---This one is only if you’d find that `script.update()` happens a bit too early for you.
---@param dt number @How much time has passed since last call, in seconds.
---@param gameDT number @How much time has passed in simulation (slower with slow-mo replays, 0 when paused), in seconds.
function script.frameBegin(dt, gameDT) end

--[[) ?]]
