__source 'extensions/new_modes/ac_ext_new_modes.cpp'
__allow 'newmodes'

require './common/internal_import'
require './common/ac_car_control'
require './common/ac_car_control_switch'
require './common/ac_audio'
require './common/ac_color_corrections'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_particles'
require './common/ac_gameplay'
require './common/ac_game'
require './common/ac_physics'
require './common/ac_physics_ai'
require './wfx_common/ac_weatherconditions'

---@param message string
---@param successfulRun boolean? @Default value: `true`.
---@param sessionResults {cancelled: boolean?, place: integer?, summary: string, message: string}? @Use `1` for gold medal and `4` as an unremarkable place. Default value: `nil`.
---@return boolean @Returns `false` if the call is inappropriate.
function ac.endSession(message, successfulRun, sessionResults)
  ffi.C.lj_endSession_inner__newmodes(tostring(message), not not successfulRun, sessionResults and JSON.stringify(sessionResults) or nil)
end

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---If script would use `ac.setStartMessage('Some message')` at its initialization, mode would switch to a preparation stage,
---during which `prepare()` function will be called each frame. Once it returns `true`, signaling that everything is ready
---to run, mode would go back to running stage, in which `prepare()` would no longer be called and instead `update()` would
---be called each frame.
---@param dt number @Time of a frame, in seconds.
---@return boolean @True if it’s time to start the race/drive/challenge/etc.
function script.prepare(dt) end

---Called each frame when mode is not in preparation stage. See `prepare()` for more details.
---@see script.prepare
---@param dt number @Time of a frame, in seconds.
function script.update(dt) end

---Called when rendering transparent objects (which are rendered after opaque objects). Draw any of your own debug shapes here,
---so they’d be on top of everything else spared by ExtraFX post-processing.
function script.draw3D() end

---Called when tool is shown. Script as a whole would run the moment tool is shown, but it would not stop when tool is closed.
---It might be a good idea to stop processin with `onHide()` and continue with `onShow()`.
function script.drawUI() end

--[[) ?]]
