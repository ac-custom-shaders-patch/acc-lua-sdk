__source 'extensions/lua_tools/ac_ext_lua_tools.cpp'
__allow 'luatools'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_physics'
require './common/ac_game'
require './common/ac_car_control'

-- automatically generated entries go here:
__definitions()

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

---Called right after core sim entities were updated. Good moment to update things on our own, like move
---objects and such.
---@param dt number @How much time has passed since last call, in seconds.
function script.simUpdate(dt) end

---Called at the beginning of a frame, before all rendering starts.
---@param dt number @How much time has passed since last call, in seconds.
---@param gameDT number @How much time has passed in simulation (slower with slow-mo replays, 0 when paused), in seconds.
function script.frameBegin(dt, gameDT) end

---Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here.
function script.draw3D() end

---Called when tool is shown. Script as a whole would run the moment tool is shown, but it would not stop when tool is closed.
---It might be a good idea to stop processin with `onHide()` and continue with `onShow()`.
function script.onShow() end

---Called when tool is hidden. Script as a whole would run the moment tool is shown, but it would not stop when tool is closed.
---It might be a good idea to stop processin with `onHide()` and continue with `onShow()`.
function script.onHide() end

---Called when replay starts. If you have any race-only things happening, like maybe a safe car animation, that would be the good
---time to hide them.
---
---(Some API to record things into replay and play them back will be added later, hopefully.)
function script.onReplayStart() end

---Called when replay stops. If you have any race-only things happening, like maybe a safe car animation, that would be the good
---time to show them back (if you hid them in `script.onReplayStart()`).
---
---(Some API to record things into replay and play them back will be added later, hopefully.)
function script.onReplayStop() end

--[[) ?]]
