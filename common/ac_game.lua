__source 'lua/api_game.cpp'
__allow 'game'

ac.PhysicsDebugLines = __enum({ cpp = 'phys_debug_lines_switches' }, { 
  None = 0,
  Tyres = 1,         -- Tyres raycasting
  WetSkidmarks = 2,  -- Marks left by tyres reducing grip in rain
})

ac.LightsDebugMode = __enum({ cpp = 'lights_debug_mode' }, { 
  Off = 0, -- @hidden
  None = 0,
  Outline = 1,
  BoundingBox = 2,
  BoundingSphere = 4,
  Text = 8,
})

ac.VAODebugMode = __enum({ cpp = 'vao_mode' }, { 
  Active = 1,
  Inactive = 3,
  VAOOnly = 4,
  ShowNormals = 5
})

ac.ScreenshotFormat = __enum({ cpp = 'screenshot_format' }, {
  Auto = 0, -- As configured in AC system settings
  BMP = 1,
  JPG = 2,
  JPEG = 2,
  PNG = 3,
  DDS = 4,
})

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

---@alias ac.ControlButtonModifiers {ctrl: boolean, shift: boolean, alt: boolean, ignore: boolean, gamepad: boolean}

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
    if modifiers.gamepad then m = -2 end
  end
  return ffi.gc(ffi.C.lj_binaryinput_new__game(tostring(id), tonumber(key) or 0, m, tonumber(repeatPeriod) or 1e9), ffi.C.lj_binaryinput_gc__game)
end

---Returns VRAM stats if available (older versions of Windows won’t provide access to this API). All sizes are in megabytes. Note: values
---provided are for a GPU in general, not for the Assetto Corsa itself.
---@return nil|{budget: number, usage: number, availableForReservation: number, reserved: number}
function ac.getVRAMConsumption()
  local r = ffi.C.lj_getVRAMConsumption_inner__game()
  if r.x == -1 then return nil end
  return { budget = r.x, usage = r.y, availableForReservation = r.z, reserved = r.w }
end

---For internal use.
---@class ac.ControlButton
---@explicit-constructor ac.ControlButton
ffi.metatype('binaryinput', {
  __index = {
    ---Button is configured.
    ---@return boolean
    configured = ffi.C.lj_binaryinput_set__game,

    ---Button was just pressed.
    ---@return boolean
    pressed = ffi.C.lj_binaryinput_pressed__game,

    ---Button is held down.
    ---@return boolean
    down = ffi.C.lj_binaryinput_down__game,

    ---Use within UI function to draw an editing button.
    ---@param size vec2?
    ---@return boolean
    control = function(s, size) 
      return ffi.C.lj_binaryinput_control__game(s, __util.ensure_vec2(size))
    end,

    ---@param value boolean? @Default value: `true`.
    ---@return ac.ControlButton
    setAlwaysActive = function(s, value)
      ffi.C.lj_binaryinput_setalwaysactive__game(s, value ~= false)
      return s
    end
  }
})
