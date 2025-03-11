__source 'extensions/gamepad_fx/ac_ext_gamepad_fx.cpp'
__states 'extensions/gamepad_fx/ac_ext_gamepad_fx.cpp'
__allow 'joypadassist'

--[[? ctx.flags.physicsThread = true; ?]]
require './common/internal_import'
require './common/ac_car_control'
require './common/ac_car_control_physics'
require './common/ac_joypad_assist_enums'
require './common/ac_extras_binaryinput'

-- automatically generated entries go here:
__definitions()

-- script format:
---Note: joypad assist script runs from physics thread, so update rate is much higher. Please keep it in mind and keep
---code as fast as possible.
---@class ScriptData
---@field update fun(dt: number) @Called each physics frame. Param `dt` is time since the last call of `.update()` in seconds. Usually would be around 0.003.
---@single-instance
script = {}

---Reference to information about state of associated car.
---@type ac.StateCar
car = nil

---Reference to information about state of simulation.
---@type ac.StateSim
sim = nil

function __script.__init__()
  car = ac.getCar(__carIndex)
  sim = ac.getSim()
end

--[[? if (ctx.ldoc) out(]]

---Index of connected car.
---@type number
__carIndex = nil

---Index of connected gamepad.
---@type number
__gamepadIndex = nil

---Loads a separate Lua module running in render thread (for showing bits of UI or updating some other in-game elements).
---@param name string @File name (without extension) of a module to load to run in render thread.
function ac.loadRenderThreadModule(name) end

---Loads a separate Lua module running in gamepad thread (for overriding gamepad buttons directly even when sim is paused).
---@param name string @File name (without extension) of a module to load to run in render thread.
function ac.loadGamepadThreadModule(name) end

---Forces state of a gamepad button to pressed for the next frame. Only available from physics thread module.
---@param gamepadButtonID ac.GamepadButton
function ac.setButtonPressed(gamepadButtonID) end

--[[) ?]]
