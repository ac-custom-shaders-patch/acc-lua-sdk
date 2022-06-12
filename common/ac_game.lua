__source 'lua/api_game.cpp'
__allow 'game'

ffi.cdef [[ 
typedef struct {
  vec3 position;
  float pitch;
  float yaw;
} seatparams;
]]

---Driver seat parameters.
---@class ac.SeatParams
---@field position vec3 @Driver eyes position. Starting value is taken from “GRAPHICS/DRIVEREYES” from “car.ini”.
---@field pitch number @Pitch angle in degrees. Starting value is taken from “GRAPHICS/ON_BOARD_PITCH_ANGLE” from “car.ini”.
---@field yaw number @Yaw angle in degrees. Starting value is 0.
ac.SeatParams = ffi.metatype('seatparams', { __index = {} })



ffi.cdef [[ 
typedef struct {
  void* __something;
} binaryinput;
]]

---@alias ac.ControlButtonModifiers {ctrl: boolean, shift: boolean, alt: boolean, ignore: boolean}

---@param id string
---@param key ui.KeyIndex?
---@param modifiers ac.ControlButtonModifiers?
---@param repeatPeriod number?
---@return ac.ControlButton
function ac.ControlButton(id, key, modifiers, repeatPeriod)
  local m = 0
  if type(modifiers) == 'table' then
    if modifiers.ctrl then m = m + 2 end
    if modifiers.shift then m = m + 8 end
    if modifiers.alt then m = m + 4 end
    if modifiers.ignore then m = -1 end
  end
  return ffi.gc(ffi.C.lj_binaryinput_new__game(tostring(id), tonumber(key) or 0, m, tonumber(repeatPeriod) or 1e9), ffi.C.lj_binaryinput_gc__game)
end

---For internal use.
---@class ac.ControlButton
---@explicit-constructor ac.ControlButton
ffi.metatype('binaryinput', {
  __index = {
    ---@return boolean
    configured = ffi.C.lj_binaryinput_set__game,

    ---@return boolean
    pressed = ffi.C.lj_binaryinput_pressed__game,

    ---@return boolean
    down = ffi.C.lj_binaryinput_down__game
  }
})
