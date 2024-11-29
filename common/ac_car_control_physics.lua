__source 'lua/api_car_control_physics.cpp'
__allow 'carc'

ffi.cdef [[ 
typedef struct {
  bool unavailable;
  bool holdMode;
  bool stationaryOnly;
  bool neutralGearOnly;
  bool requiresBrake;
} extra_switch_params;
]]

---A helper structure to simulate some inputs for controlling the car.
---@class ac.CarExtraSwitchParams
---@field unavailable boolean @Set to `true` to make a switch inaccessible by user with hotkeys. Car controlling scripts would still be able to alter its state.
---@field holdMode boolean @Set to `true` to get switch to work only if a button is currently held down.
---@field stationaryOnly boolean @Set to `true` to only allow user to change the flag if car is stationary.
---@field neutralGearOnly boolean @Set to `true` to only allow user to change the flag if car is in neutral gear.
---@field requiresBrake boolean @Set to `true` to only allow user to change the flag if brake pedal is fully pressed.
---@cpptype extra_switch_params
ffi.metatype('extra_switch_params', { __index = {} })

---@param index integer @0-based switch index.
---@return ac.CarExtraSwitchParams? @Returns `nil` if there is no switch with such index.
function ac.accessExtraSwitchParams(index)
  local r = ffi.C.lj_accessExtraSwitchParams_inner__carc(tonumber(index) or 0)
	return r ~= nil and r or nil
end
