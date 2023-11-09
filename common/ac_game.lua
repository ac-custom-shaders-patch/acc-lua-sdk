__source 'lua/api_game.cpp'
__allow 'game'

require './ac_game_enums'

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
  int forceHighBeams;
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
---@field forceHighBeams ac.SceneTweakFlag 
---@field timeOffset number
---@field headingAngleOffset number
---@field forceFlames boolean
---@field stationaryRainDrops boolean
---@field disableDamage boolean
---@field disableDirt boolean
ac.SceneTweaks = ffi.metatype('camera_scene_adjustments', { __index = {} })

---Returns VRAM stats if available (older versions of Windows won’t provide access to this API). All sizes are in megabytes. Note: values
---provided are for a GPU in general, not for the Assetto Corsa itself.
---@return nil|{budget: number, usage: number, availableForReservation: number, reserved: number}
function ac.getVRAMConsumption()
  local r = ffi.C.lj_getVRAMConsumption_inner__game()
  if r.x == -1 then return nil end
  return { budget = r.x, usage = r.y, availableForReservation = r.z, reserved = r.w }
end

ffi.cdef [[ 
typedef struct {
  const float range;
  const float applied;
  float input;
} driverweightshift;
]]

---Driver seat parameters.
---@class ac.DriverWeightShift
---@field range number @Maximum range in meters. Read only.
---@field applied number @Applied shift in meters. Read only.
---@field input number @Requested shift in meters. Can be altered.
ffi.metatype('driverweightshift', { __index = {} })

---Access driver weight shift.
---@param carIndex integer @0-based car index.
---@return ac.DriverWeightShift?
function ac.DriverWeightShift(carIndex)
  local r = ffi.C.lj_accessDriverWeightShift_inner__game(tonumber(carIndex) or 0)
  if r == nil then return nil end
  return r
end




ffi.cdef [[ 
typedef struct {
  uint64_t _lastActiveFrame;
  bool headlights;
  bool headlightsFlash;
  bool changeCamera;
  bool horn;
  bool lookLeft;
  bool lookRight;
  bool lookBack;
  bool _pad;
  bool gearUp;
  bool gearDown;
  int8_t drs;
  int8_t kers;
  bool brakeBalanceUp;
  bool brakeBalanceDown;
  int requestedGearIndex;
  bool __pad;
  float handbrake;
  bool absUp;
  bool absDown;
  bool tractionControlUp;
  bool tractionControlDown;
  bool turboUp;
  bool turboDown;
  bool engineBrakeUp;
  bool engineBrakeDown;
  bool mgukDeliveryUp;
  bool mgukDeliveryDown;
  bool mgukRecoveryUp;
  bool mgukRecoveryDown;
  int8_t mguhMode;
  float gas;
  float brake;
  float steer;
  float clutch;
} carcontrolsoverride;
]]

---A helper structure to simulate some inputs for controlling the car.
---@class ac.CarControlsInput
---@field gearUp boolean @Set to `true` to activate a flag for the next physics step.
---@field gearDown boolean @Set to `true` to activate a flag for the next physics step.
---@field brakeBalanceUp boolean @Set to `true` to activate a flag for the next physics step.
---@field brakeBalanceDown boolean @Set to `true` to activate a flag for the next physics step.
---@field absUp boolean @Set to `true` to activate a flag for the next physics step.
---@field absDown boolean @Set to `true` to activate a flag for the next physics step.
---@field tractionControlUp boolean @Set to `true` to activate a flag for the next physics step.
---@field tractionControlDown boolean @Set to `true` to activate a flag for the next physics step.
---@field turboUp boolean @Set to `true` to activate a flag for the next physics step.
---@field turboDown boolean @Set to `true` to activate a flag for the next physics step.
---@field engineBrakeUp boolean @Set to `true` to activate a flag for the next physics step.
---@field engineBrakeDown boolean @Set to `true` to activate a flag for the next physics step.
---@field mgukDeliveryUp boolean @Set to `true` to activate a flag for the next physics step.
---@field mgukDeliveryDown boolean @Set to `true` to activate a flag for the next physics step.
---@field mgukRecoveryUp boolean @Set to `true` to activate a flag for the next physics step.
---@field mgukRecoveryDown boolean @Set to `true` to activate a flag for the next physics step.
---@field drs boolean @Set to `true` to switch the DRS state in the next physics step.
---@field kers ac.CarControlsInput.Flag @Set to `ac.CarControlsInput.Flag.Skip` to leave the user-selected value be.
---@field mguhMode integer @Set to `-1` to keep existing value, or to a 0-based index of the required MGUH mode.
---@field requestedGearIndex integer @Set to `0` to keep existing gear, to `-1` to engage reverse, or to a positive value to engage a regular gear.
---@field steer number @Value from -1 to 1. Set to `math.huge` to instead leave the original steering value.
---@field gas number @Value from 0 to 1. Final value will be the maximum of original and this.
---@field brake number @Value from 0 to 1. Final value will be the maximum of original and this.
---@field handbrake number @Value from 0 to 1. Final value will be the maximum of original and this.
---@field clutch number @Value from 0 to 1. Final value will be the minimum of original and this (1 is for clutch pedal fully depressed, 0 for pressed).
---@field headlights boolean @Set to `true` to toggle headlights in the next frame (after that, field will be reset).
---@field headlightsFlash boolean @Set to `true` to flash headlights in the next frame (after that, field will be reset).
---@field changeCamera boolean @Set to `true` to change camera in the next frame (after that, field will be reset).
---@field horn boolean @Set to `true` to honk. Reset to `false` when done. Note: with sirens instead of horn, behaviour might be different. 
---@field lookLeft boolean @Set to `true` to look left. Reset to `false` when done.
---@field lookRight boolean @Set to `true` to look right. Reset to `false` when done.
---@field lookBack boolean @Set to `true` to look back. Reset to `false` when done.
---@cpptype carcontrolsoverride
ffi.metatype('carcontrolsoverride', {
  __index = {
    ---Checks if controls override is active (as in, has been read by AC physics in the last couple of frames).
    ---@return boolean
    active = function (s)
      return s._lastActiveFrame + 2 > ac.getSim().frame
    end
  }
})


ffi.cdef [[ 
typedef struct {
  int displayMode;
  float _pad[3];
  bool verticalLayout;
} lua_overlay_leaderboard;
]]

---A helper structure to simulate some inputs for controlling the car.
---@class ac.OverlayLeaderboardParams
---@field displayMode integer
---@field verticalLayout boolean
---@cpptype lua_overlay_leaderboard
ffi.metatype('lua_overlay_leaderboard', { __index = {} })
