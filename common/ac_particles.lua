__source 'extensions/particles_fx/ac_ext_particles_fx__lua.h'

---Table with different types of emitters.
ac.Particles = {}

-- Flames particles:

ffi.cdef [[ 
typedef struct { rgbm color; float size; float temperatureMultiplier; float flameIntensity; int carIndex; } pfxflameemitter;
]]

--[[@tableparam params {
  color: rgbm = rgbm(0.5, 0.5, 0.5, 0.5) "Flame color multiplier (for red/yellow/blue adjustment use `temperatureMultiplier` instead).",
  size: number = 0.2 "Particles size. Default value: 0.2.",
  temperatureMultiplier: number = 1 "Temperature multipler to vary base color from red to blue. Default value: 1.",
  flameIntensity: number = 0 "Flame intensity affecting flame look and behaviour. Default value: 0."
}]]
---@return ac.Particles.Flame
function ac.Particles.Flame(params)
  local created = ffi.gc(ffi.C.lj_pfxflameemitter_new(), ffi.C.lj_pfxflameemitter_gc)
  if params then for k, v in pairs(params) do created[k] = v end end
  return created
end

---Flame emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit flames.
---@class ac.Particles.Flame
---@field color rgbm @Flame color multiplier (for red/yellow/blue adjustment use `temperatureMultiplier` instead).
---@field size number @Particles size. Default value: 0.2.
---@field temperatureMultiplier number @Temperature multipler to vary base color from red to blue. Default value: 1.
---@field flameIntensity number @Flame intensity affecting flame look and behaviour. Default value: 0.
---@field carIndex number @0-based index of a car associated with flame emitter (affects final look).
---@explicit-constructor ac.Particles.Flame
ffi.metatype('pfxflameemitter', {
  __index = {
    ---Emits flames from given position with certain velocity.
    emit = function (s, position, velocity, amount)
      ffi.C.lj_pfxflameemitter_emit(s, __util.ensure_vec3(position), __util.ensure_vec3(velocity), tonumber(amount) or 1)
    end,
  }
})

-- Sparks particles:

ffi.cdef [[ 
typedef struct { rgbm color; float life; float size; float directionSpread; float positionSpread; } pfxsparksemitter;
]]

--[[@tableparam params {
  color: rgbm = rgbm(0.5, 0.5, 0.5, 0.5) "Sparks color.",
  life: number = 4 "Base lifetime. Default value: 4.",
  size: number = 0.2 "Base size. Default value: 0.2.",
  directionSpread: number = 1 "How much sparks directions vary. Default value: 1.",
  positionSpread: number = 0.2 "How much sparks position vary. Default value: 0.2."
}]]
---@return ac.Particles.Sparks
function ac.Particles.Sparks(params)
  local created = ffi.gc(ffi.C.lj_pfxsparksemitter_new(), ffi.C.lj_pfxsparksemitter_gc)
  if params then for k, v in pairs(params) do created[k] = v end end
  return created
end

---Sparks emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit sparks.
---@class ac.Particles.Sparks
---@field color rgbm @Sparks color.
---@field life number @Base lifetime. Default value: 4.
---@field size number @Base size. Default value: 0.2.
---@field directionSpread number @How much sparks directions vary. Default value: 1.
---@field positionSpread number @How much sparks position vary. Default value: 0.2.
---@explicit-constructor ac.Particles.Sparks
ffi.metatype('pfxsparksemitter', {
  __index = {
    ---Emits sparks from given position with certain velocity.
    emit = function (s, position, velocity, amount)
      ffi.C.lj_pfxsparksemitter_emit(s, __util.ensure_vec3(position), __util.ensure_vec3(velocity), tonumber(amount) or 1)
    end,
  }
})

-- Smoke particles:

ffi.cdef [[ 
typedef struct { rgbm color; float colorConsistency; float thickness; float life; float size; float spreadK; float growK; float targetYVelocity; } pfxsmokeemitter;
]]

--[[@tableparam params {
  color: rgbm = rgbm(0.5, 0.5, 0.5, 0.5) "Smoke color with values from 0 to 1. Alpha can be used to adjust thickness. Default alpha value: 0.5.",
  colorConsistency: number = 0.5 "Defines how much color dissipates when smoke expands, from 0 to 1. Default value: 0.5.",
  thickness: number = 1 "How thick is smoke, from 0 to 1. Default value: 1.",
  life: number = 4 "Smoke base lifespan in seconds. Default value: 4.",
  size: number = 0.2 "Starting particle size in meters. Default value: 0.2.",
  spreadK: number = 1 "How randomized is smoke spawn (mostly, speed and direction). Default value: 1.",
  growK: number = 1 "How fast smoke expands. Default value: 1.",
  targetYVelocity: number = 0 "Neutral vertical velocity. Set above zero for hot gasses and below zero for cold, to collect at the bottom. Default value: 0."
}]]
---@return ac.Particles.Smoke
function ac.Particles.Smoke(params)
  local created = ffi.gc(ffi.C.lj_pfxsmokeemitter_new(), ffi.C.lj_pfxsmokeemitter_gc)
  if params then for k, v in pairs(params) do created[k] = v end end
  return created
end

---Smoke emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit smoke.
---@class ac.Particles.Smoke
---@field color rgbm @Smoke color with values from 0 to 1. Alpha can be used to adjust thickness. Default alpha value: 0.5.
---@field colorConsistency number @Defines how much color dissipates when smoke expands, from 0 to 1. Default value: 0.5.
---@field thickness number @How thick is smoke, from 0 to 1. Default value: 1.
---@field life number @Smoke base lifespan in seconds. Default value: 4.
---@field size number @Starting particle size in meters. Default value: 0.2.
---@field spreadK number @How randomized is smoke spawn (mostly, speed and direction). Default value: 1.
---@field growK number @How fast smoke expands. Default value: 1.
---@field targetYVelocity number @Neutral vertical velocity. Set above zero for hot gasses and below zero for cold, to collect at the bottom. Default value: 0.
---@explicit-constructor ac.Particles.Smoke
ffi.metatype('pfxsmokeemitter', {
  __index = {
    ---Emits smoke from given position with certain velocity.
    emit = function (s, position, velocity, amount)
      ffi.C.lj_pfxsmokeemitter_emit(s, __util.ensure_vec3(position), __util.ensure_vec3(velocity), tonumber(amount) or 1)
    end,
  }
})

-- Smoke detractors:

ffi.cdef [[ 
typedef struct { float radius; float forceMultiplier; vec3 velocity; vec3 position; } pfxsmokedetractor;
]]

--[[@tableparam params {
  position: vec3 = nil "Detractor position",
  velocity: vec3 = nil "Detractor velocity (main value that is used to push particles; stationary detractors don’t have much effect)",
  radius: number = 10 "Radius of the effect",
  forceMultiplier: number = 1 "Force multiplier of the effect"
}]]
---@return ac.Particles.Detractor
function ac.Particles.Detractor(params)
  local created = ffi.gc(ffi.C.lj_pfxsmokedetractor_new(), ffi.C.lj_pfxsmokedetractor_gc)
  if params then for k, v in pairs(params) do created[k] = v end end
  return created
end

---Particles detractor pushing smoke (and othe particles later) away. Move it somewhere, set radius
---and velocity and it would affect the smoke.
---
---Note: use carefully, smoke particles can only account for eight detractors at once, and some of them can be set
---by track config. Also, moving cars or exhaust flames push smoke away using the same system.
---@class ac.Particles.Detractor
---@field position vec3 @Detractor position.
---@field velocity vec3 @Detractor velocity (main value that is used to push particles; stationary detractors don’t have much effect).
---@field radius number @Radius of the effect. Default value: 10.
---@field forceMultiplier number @Force multiplier of the effect. Default value: 1.
---@explicit-constructor ac.Particles.Detractor
ffi.metatype('pfxsmokedetractor', {
  __index = {}
})
