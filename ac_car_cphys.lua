__source 'custom_physics/cphys_script.cpp'
__states 'custom_physics/cphys_script.cpp'
__allow 'cphys'

require './common/internal_import'

--[[ ac.TractionType = __enum({ cpp = 'TractionType' }, {
  RWD = 0,
  FWD = 1,
  AWD = 2,
  AWD2 = 3,
}) ]]

-- automatically generated entries go here:
__definitions()

-- extra additions:

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

--[[) ?]]
