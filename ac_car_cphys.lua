__source 'custom_physics/cphys_script.cpp'
__states 'custom_physics/cphys_script.cpp'
__allow 'cphys'

require './common/internal_import'
require './common/secure'

ffi.cdef [[ 
typedef struct {
  float reboundSlow;
  float reboundFast;
  float bumpSlow;
  float bumpFast;
  float fastThresholdBump;
  float fastThresholdRebound;
} state_cphys_damper;

typedef struct {
  const wchar_t _0[62];
  const uint _1;
  const float _2;
  const void* _3;
  const float grip;
  const int sectorID;
  const float dirt;
  const uint collisionCategory;
  const bool isValidTrack;
  const float blackFlagTime;
  const float sinHeight;
  const float sinLength;
  const bool isPitlane;
  const float damping;
  const float granularity;
  const float vibrationGain;
  const float vibrationLength;
} state_cphys_surface;
]]

---Holds state of an AC damper available for both reading and writing.
---@class ac.StateCphysDamper
---@field reboundSlow number
---@field reboundFast number
---@field bumpSlow number
---@field bumpFast number
---@field fastThresholdBump number
---@field fastThresholdRebound number
ffi.metatype('state_cphys_damper', { __index = {
} })

---Holds state of an AC track surface available for reading only.
---@class ac.StateCphysSurface
---@field grip number
---@field sectorID integer
---@field dirt number
---@field collisionCategory integer
---@field isValidTrack boolean
---@field blackFlagTime number
---@field sinHeight number
---@field sinLength number
---@field isPitlane boolean
---@field damping number
---@field granularity number
---@field vibrationGain number
---@field vibrationLength number
ffi.metatype('state_cphys_surface', { __index = {
} })

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

---Called when car resets or teleports, for example teleporting to pits, or when a new session starts.
function script.reset() end

--[[) ?]]
