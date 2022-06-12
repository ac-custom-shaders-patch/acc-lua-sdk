__source 'extensions/joypad_assist/ac_ext_joypad_assist.cpp'
__states 'extensions/joypad_assist/ac_ext_joypad_assist.cpp'
__allow 'joypadassist'

require './common/internal_import'

-- automatically generated entries go here:
__definitions()

-- script format:
---Note: joypad assist script runs from physics thread, so update rate is much higher. Please keep it in mind and keep
---code as fast as possible.
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Index of connected gamepad.
---@type number
__gamepadIndex = nil

---Called each physics frame.
---@param dt number @Time passed since last `update()` call, in seconds. Usually would be around 0.003.
function script.update(dt) end

--[[) ?]]
