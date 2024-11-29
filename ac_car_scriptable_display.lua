__source 'extensions/car_instruments/car_scriptable_display.cpp'
__allow 'csd'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_ui'
require './common/ac_display'
require './common/ac_particles'
require './common/ac_scene'
require './common/ac_ray'
require './common/ac_car_control'
require './common/ac_car_control_physics'
require './common/ac_physics_raycast'
require './common/ac_extras_binaryinput'
require './car_scriptable_display/car_scriptable_display_structs'
require './car_scriptable_display/car_scriptable_display_utils'
require './common/secure'

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

---Returns values from section which defined current display. Use `layout` to specify which
---values are needed, with their corresponding default values to determine types. This function
---can be used to configure script from config, allowing to create customizable scripts which
---would act as new types of displays, especially if used with INIpp templates.
---
---Note: consider using lowerCamelCase for keys to make sure there wouldn’t be a collision with
---CSP parameters for scriptable displays, as well as with INIpp template parameters (which use UpperCamelCase).
---
---You can achieve the same results by using `ac.getCarConfig()` (name of section which creates script
---is available in `__cfgSection__` global variable). This is just a shortcut to make things nicer.
---@generic T
---@param layout T
---@return T
function ac.configValues(layout)
  return table.map(layout, function (item, index) return ac.getCarConfig(__carindex__ - 1, __cfgSection__, index, item), index end)
end

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each time display updates.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

--[[) ?]]
