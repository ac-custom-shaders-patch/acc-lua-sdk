__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__allow 'impl'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_color_corrections'
require './common/ac_light'
require './common/ac_render'
require './common/ac_scene'
require './common/ac_ray'
require './wfx_common/ac_weatherconditions'
require './wfx_impl/ac_clouds'
require './wfx_impl/ac_cloudscovers'
require './wfx_impl/ac_gradients'
require './wfx_impl/ac_particlematerials'
require './wfx_impl/ac_lightpollution'
require './wfx_impl/ac_obsolete'
require './wfx_impl/ac_lists'

-- automatically generated entries go here:
__definitions()

---Sets value of a track condition input.
---@param key string @Name of an input.
---@param value number @New input value.
function ac.setTrackCondition(key, value)
  ffi.C.lj_set_track_condition__impl(__util.str(key), tonumber(value) or 0)
end

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Changes to true, if `script.asyncUpdate()` function is defined and being called.
__withAsyncUpdate = false

---Called each frame.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

---Called after `update()` from a different thread. Use it for some background processing, but do not use any AC CSP API which.
---might affect state of AC itself. If `asyncUpdate()` would not finish its job by the time another function would be called,
---whole AC would pause waiting for it.
---@param dt number @Same time as was just passed to `update()`.
function script.asyncUpdate(dt) end

--[[) ?]]

