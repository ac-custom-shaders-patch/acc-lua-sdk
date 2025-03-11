require './common/internal_import'
__source 'extensions/ffb_tweaks/ffb_postprocess_script.cpp'
__states 'extensions/ffb_tweaks/ffb_postprocess_script.cpp'

--[[? ctx.flags.physicsThread = true; ?]]
require './common/ac_extras_binaryinput'

-- automatically generated entries go here:
__definitions()

---Reference to information about state of associated car. To access details at physics rate, use `ac.getCarPhysicsRate()`.
---@type ac.StateCar
car = nil

---Reference to information about state of simulation.
---@type ac.StateSim
sim = nil

function __script.__init__()
  car = ac.getCar(__carindex__ - 1)
  sim = ac.getSim()
end

-- script format:
---Note: joypad assist script runs from physics thread, so update rate is much higher. Please keep it in mind and keep
---code as fast as possible.
---@class ScriptData
---@field update fun(ffbValue: number, ffbDamper: number, steerInput: number, steerInputSpeed: number, dt: number): number, number @Called each physics frame. Takes original FFB force and damper as `ffbValue` and `ffbDamper`, expected to return new FFB force and damper values. Param `dt` is time since the last call of `.update()` in seconds, usually around 0.003.
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Disable low speed FFB reduction.
---@param disable boolean? @Default value: `true`.
function ac.disableLowSpeedFFBReduction(disable) end

--[[) ?]]