__source 'extensions/track_adjustments/track_scriptable_display.cpp'
__source 'extensions/online_plus/online_scripts.cpp'
__allow 'tsd'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_physics'
require './common/secure'

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

if __mode__ == 'server_script' then

---For online scripts only. Reconnect to a different server (or, if `params` is not set or empty, same server).
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
  if __mode__ == 'server_script' then
    return table.map(layout, function (item, index) return __getServerConfig(__cfgSection__, index, item), index end)
  end
  return table.map(layout, function (item, index) return ac.getTrackConfig(__cfgSection__, index, item), index end)
end

-- access to track conditions
ffi.cdef [[ typedef struct { void* __data[4]; } trackcondition; ]]

---@param expression string @Expression similar to ones config have as CONDITION=… value.
---@param offset number @Condition offset. Default value: 0.
---@param defaultValue number @Default value in case referenced condition is missing or parsing failed. Default value: 0.
---@return ac.TrackCondition
function ac.TrackCondition(expression, offset, defaultValue)
  return ffi.gc(
    ffi.C.lj_trackcondition_new__tsd(__util.str(expression), tonumber(offset) or 0, tonumber(defaultValue) or 0),
    ffi.C.lj_trackcondition_gc__tsd)
end

---Track condition evaluator. Given expression, which might refer to some existing condition, condition input or a complex expression of those,
---computes the resulting value.
---@class ac.TrackCondition
ffi.metatype('trackcondition', { __index = {
  ---@return number
  get = function (s) return ffi.C.lj_trackcondition_get__tsd(s) end,
  ---@return rgb
  getColor = function (s) return ffi.C.lj_trackcondition_getcolor__tsd(s) end,
  ---@return boolean
  isDynamic = function (s) return ffi.C.lj_trackcondition_isdynamic__tsd(s) end,
} })

---Finds a car at a given place in a race, for creating leaderboards. Returns nil if couldn’t find a car.
---@param place integer @Starts with 1 for first place.
---@return ac.StateCar|nil
function ac.findCarAtPlace(place)
  for i = 0, #ac.getSim().carsCount - 1 do  -- getCar() needs IDs from 0 to N-1
    local car = ac.getCar(i)
    if car.racePosition == place then return car end
  end
  return nil -- couldn’t find anything
end

-- automatically generated entries go here:
__definitions()

-- extra additions:
---@type ac.StateSim
sim = nil
function __script.__init__()
  sim = ac.getSim()
end

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---For `[SCRIPTABLE_DISPLAY_...]` called when display updates. For `[SCRIPT_...]` called when sim updates.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

---Only for `[SCRIPT_...]`. Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here.
function script.draw3D() end

---Only for `[SCRIPT_...]`. Called at the beginning of a frame, before all rendering starts. If you want to move things, `script.update()` might be a better option.
---This one is only if you’d find that `script.update()` happens a bit too early for you.
---@param dt number @How much time has passed since last call, in seconds.
---@param gameDT number @How much time has passed in simulation (slower with slow-mo replays, 0 when paused), in seconds.
function script.frameBegin(dt, gameDT) end

---Only for `[SCRIPT_...]`. Called when replay starts. If you have any race-only things happening, like maybe a safe car animation, that would be the good
---time to hide them.
---
---(Some API to record things into replay and play them back will be added later, hopefully.)
function script.onReplayStart() end

---Only for `[SCRIPT_...]`. Called when replay stops. If you have any race-only things happening, like maybe a safe car animation, that would be the good
---time to show them back (if you hid them in `script.onReplayStart()`).
---
---(Some API to record things into replay and play them back will be added later, hopefully.)
function script.onReplayStop() end

--[[) ?]]
