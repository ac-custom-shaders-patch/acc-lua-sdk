__source 'extensions/chaser_camera/ac_ext_chaser_camera.cpp'

require './common/internal_import'
require './inc_scene'

-- automatically generated entries go here:
__definitions()

-- extra additions:

---Reference to information about state of associated car.
---@type ac.StateCar
car = nil

---Reference to information about state of simulation.
---@type ac.StateSim
sim = nil

function __script.updateState(carIndex)
  if not car or car.index ~= carIndex then
    car = ac.getCar(carIndex)
    if not sim then
      sim = ac.getSim()
    elseif type(script.onCarChanged) == 'function' then
      script.onCarChanged()
    end
  end
end

---Gets chase camera settings.
---@return { distance: number, height: number, pitch: number }
function ac.getCameraParameters(index)
  local parameters = ffi.C.lj_get_camera_params_as_vec3(index)
  return { distance = parameters.x, height = parameters.y, pitch = parameters.z }
end

---@return vec2
function ac.getJoystickLook()
  local parameters = ffi.C.lj_get_joystick_look()
  return parameters.x ~= 0 and vec2(parameters.y, parameters.z) or nil
end

---Simple helper wrapping calls to `ac.looksLeft()`, `ac.getJoystickLook()` and such and returning a single number.
---If it’s 0.5, user wants to look to the left. If -0.5, to the right. If 1 or -1, behind (either over left or right shoulder).
---@return number
function ac.getDesiredLookDirection()
  local joystickLook = ac.getJoystickLook()
  local baseLookDir = (ac.looksLeft() and ac.looksRight() or ac.looksBehind()) and math.sign(lookDirection()) or
    ac.looksLeft() and 0.5 or
    ac.looksRight() and -0.5 or nil
  return joystickLook ~= nil and (not baseLookDir or math.abs(joystickLook.x) > 0.1) 
    and joystickLook.x or baseLookDir or 0
end

-- script format:
---@class ScriptData
---@field update fun(dt: number) @Called each frame. Param `dt` is time since the last call of `.update()` in seconds.
---@field onCarChanged fun() @Called when selected car changes mid-run (won’t be called at the start). By the time it’s called, `car` has already been updated.
---@single-instance
script = {}

