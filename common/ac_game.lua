__source 'lua/api_game.cpp'
__source 'lua/api_replay_extension.cpp'
__allow 'game'

ac.PhysicsDebugLines = __enum({ cpp = 'phys_debug_lines_switches' }, { 
  None = 0,
  Tyres = 1,         -- Tyres raycasting
  WetSkidmarks = 2,  -- Marks left by tyres reducing grip in rain
  Script = 4,        -- Lines drawn by custom physics script
  RainLane = 65536,  -- Alternative AI lane for rain
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

ac.SceneTweakFlag = __enum({}, {
  Default = 0,
  ForceOn = 1,
  ForceOff = 2,
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
  int forceHeadlights;
  int forceBrakeLights;
  float timeOffset;
  float headingAngleOffset;
  bool forceFlames;
  bool stationaryRainDrops;
  bool disableDamage;
  bool disableDirt;
} camera_scene_adjustments;
]]

---Driver seat parameters.
---@class ac.SceneTweaks
---@field forceHeadlights ac.SceneTweakFlag 
---@field forceBrakeLights ac.SceneTweakFlag 
---@field timeOffset number
---@field headingAngleOffset number
---@field forceFlames boolean
---@field stationaryRainDrops boolean
---@field disableDamage boolean
---@field disableDirt boolean
ac.SceneTweaks = ffi.metatype('camera_scene_adjustments', { __index = {} })

ffi.cdef [[ 
typedef struct {
  void* __something;
} binaryinput;
]]

---@alias ac.ControlButtonModifiers {ctrl: boolean, shift: boolean, alt: boolean, ignore: boolean, gamepad: boolean, system: boolean}

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
    if modifiers.system then m = -3 end
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

local _rpsActive = {}
ffi.cdef [[ 
typedef struct {
  void* _frame;
} replayextension;
]]

---Create a new stream for recording data to replays. Write data in returned structure if not in replay mode, read data if in replay mode (use `sim.isReplayActive` to check if you need to write or read the data).
---Few important points:
--- - Each frame should not exceed 256 bytes to keep replay size appropriate.
--- - While data will be interpolated between frames during reading, directional vectors won’t be re-normalized. 
--- - If two different apps would open a stream with the same layout, they’ll share a replay entry.
--- - Each opened replay stream will persist through the entire AC session to be saved at the end. Currently, the limit is 128 streams per session.
--- - Default values for unitialized frames are zeroes.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Unlike other similar functions, here you shouldn’t use string, otherwise data blending won’t work.
---@param callback fun()? @Callback that will be called when replay stops. Use this callback to re-apply data from structure: at the moment of the call it will contain stuff from last recorded frame allowing you to restore the state of a simulation to when replay mode was activated.
---@return T? @Might return `nil` if there is game is launched in replay mode and there is no such data stored in the replay.
function ac.ReplayStream(layout, callback)
  local layoutStr, reordered = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end
  if layoutStr:match('%(') then error('Invalid layout', 2) end

  local name = '__rps_'..tostring(ac.checksumXXH(layoutStr))
  local ret = _rpsActive[name]
  if ret == nil then
    ffi.cdef(ac.StructItem.__cdef(name, layoutStr, true))
    local size = ffi.sizeof(name)
    local mixing = {}
    if reordered then
      local offset = 0
      for _, v in ipairs(reordered) do
        local t = v.replayType
        if t then
          for _ = 1, v.array or 1 do
            if t > 99 then
              local c = math.floor(t / 100)
              for _ = 1, c do
                mixing[#mixing + 1] = string.format('%d:%d', offset, t % 100)
                offset = offset + v.size / c
              end
            else
              mixing[#mixing + 1] = string.format('%d:%d', offset, t)
              offset = offset + v.size
            end
          end
        else
          offset = offset + v.size * (v.array or 1)
        end
      end
    end
    ret = ffi.gc(ffi.C.lj_replayextension_new(name, size, table.concat(mixing, '\n'), __util.setCallback(callback)), ffi.C.lj_replayextension_gc)
    _rpsActive[name] = ret
  end
  if ret._frame == nil then
    return nil
  end
  return ffi.cast(name..'*', ret._frame)
end
