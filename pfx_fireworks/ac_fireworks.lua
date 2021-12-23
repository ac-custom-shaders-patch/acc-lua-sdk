ffi.cdef [[ 
typedef struct {
  int __id;
  vec3 pos;
  vec3 velocity;

  float sparkingIntensity;
  float sparkingIntensityShot;
  float sparkingLifespan;
  float sparkingSize;
  float sparkingStretch;
  float sparkingSpeedMin;
  float sparkingSpeedMax;
  vec3 sparkingDir;
  float sparkingDirSpreadXZ;
  float sparkingDirSpreadY;
  rgb sparkingColorA;
  rgb sparkingColorB;
  float sparkingPosSpread;
  int sparkingSpreadFlags;
  float sparkingLifespanSpread;
  float sparkingSizeSpread;
  float sparkingBrightness;

  vec3 glowOffset;
  float glowBrightness;
  float glowSize;
  rgb glowColor;

  vec3 smokingPosOffset;
  float smokingIntensity;
  float smokingIntensityShot;
  float smokingLifespan;
  float smokingSize;
  float smokingOpacity;
  float smokingSpeedRandomMin;
  float smokingSpeedRandomMax;
  rgb smokingColor;
  float smokingPosSpread;
  vec3 smokingVelocityOffset;

  float pushingForce;
} firework;
]]

---@return ac.Firework
function ac.Firework() 
  local created = ffi.C.lj_firework_new()
  return ffi.gc(created, ffi.C.lj_firework_gc)
end

---@class ac.Firework
---@field pos vec3
---@field velocity vec3
---@field sparkingIntensity number
---@field sparkingIntensityShot number
---@field sparkingLifespan number
---@field sparkingSize number
---@field sparkingStretch number
---@field sparkingSpeedMin number
---@field sparkingSpeedMax number
---@field sparkingDir vec3
---@field sparkingDirSpreadXZ number
---@field sparkingDirSpreadY number
---@field sparkingColorA rgb
---@field sparkingColorB rgb
---@field sparkingPosSpread number
---@field sparkingSpreadFlags integer
---@field sparkingLifespanSpread number
---@field sparkingSizeSpread number
---@field sparkingBrightness number
---@field glowOffset vec3
---@field glowBrightness number
---@field glowSize number
---@field glowColor rgb
---@field smokingPosOffset vec3
---@field smokingIntensity number
---@field smokingIntensityShot number
---@field smokingLifespan number
---@field smokingSize number
---@field smokingOpacity number
---@field smokingSpeedRandomMin number
---@field smokingSpeedRandomMax number
---@field smokingColor rgb
---@field smokingPosSpread number
---@field smokingVelocityOffset vec3
---@field pushingForce number
ffi.metatype('firework', {
  __index = {}
})
