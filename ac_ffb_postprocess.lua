require './common/internal_import'
__source 'extensions/ffb_tweaks/ac_ext_ffb_tweaks.cpp'

--[[? ctx.flags.physicsThread = true; ?]]
require './common/ac_extras_binaryinput'

-- automatically generated entries go here:
__definitions()

---Reference to information about state of associated car.
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
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each physics frame.
---@param dt number @Time passed since last `update()` call, in seconds. Usually would be around 0.003.
function script.update(dt) end

---Disable low speed FFB reduction.
---@param disable boolean? @Default value: `true`.
function ac.disableLowSpeedFFBReduction(disable) end

--[[) ?]]