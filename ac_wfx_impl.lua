__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__source 'lua/api_wfx_apps.cpp'
__allow 'impl'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_color_corrections'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_particles'
require './common/ac_extras_backgroundworker'
require './common/ac_extras_binaryinput'
require './common/ac_extras_yebiscolorcorrection'
require './wfx_impl/ac_clouds'
require './wfx_impl/ac_cloudscovers'
require './wfx_impl/ac_gradients'
require './wfx_impl/ac_particlematerials'
require './wfx_impl/ac_lightpollution'
require './wfx_impl/ac_obsolete'
require './wfx_impl/ac_lists'
require './wfx_impl/ac_customtonemapping'
require './wfx_impl/ac_postprocessing'

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

---Called right after the sky (and sky covers) were rendered. Use `ac.enableRenderCallback()` to activate.
---@param passID render.PassID 
---@param frameIndex integer
---@param uniqueKey integer
function script.renderSky(passID, frameIndex, uniqueKey) end

---Called right after the clouds. Use `ac.enableRenderCallback()` to activate.
---@param passID render.PassID 
---@param frameIndex integer
---@param uniqueKey integer
function script.renderClouds(passID, frameIndex, uniqueKey) end

---Called right after all transparent surfaces of a track are rendered (but before transparent car surfaces). Use `ac.enableRenderCallback()` to activate.
function script.renderTrack(passID, frameIndex, uniqueKey) end

---Called right after everything is rendered (but before optional helmet of NeckFX). Use `ac.enableRenderCallback()` to activate.
function script.renderSceneEnd(passID, frameIndex, uniqueKey) end

---Called right after the cloud shadows are rendered. Use `ac.enableRenderCallback()` to activate.
function script.renderCloudShadows(passID, frameIndex, uniqueKey) end

--[[) ?]]

