__source 'lua/api_physics.cpp'
__source 'lua/api_physics_raycast.cpp'
__namespace 'physics'

require './ac_ray'

---Physics namespace. Note: functions here are accessible only if track has expicitly allowed it with its
---extended CSP physics.
---
---To allow scriptable physics, add to surfaces.ini:
---```ini
---[_SCRIPTING_PHYSICS]
---ALLOW_TRACK_SCRIPTS=1    ; choose ones that you need
---ALLOW_DISPLAY_SCRIPTS=1
---ALLOW_NEW_MODE_SCRIPTS=1
---ALLOW_TOOLS=1
---```
---
---And to activate extended physics, use:
---```ini
---[SURFACE_0]
---WAV_PITCH=extended-0
---```
physics = {}

ffi.cdef [[ typedef struct { int __id; bool __listens_for_collisions; mat4x4 __transform; } lua_rigidbody; ]]
ffi.cdef [[ typedef struct __declspec(align(4)) { 
  const bool gearUp; 
  const bool gearDown; 
  const bool drs; 
  const bool kers; 
  const bool brakeBalanceUp; 
  const bool brakeBalanceDown; 
  const int requestedGearIndex; 
  const bool isShifterSupported; 
  const float handbrake; 
  const bool absUp; 
  const bool absDown; 
  const bool tcUp; 
  const bool tcDown; 
  const bool turboUp; 
  const bool turboDown; 
  const bool engineBrakeUp; 
  const bool engineBrakeDown; 
  const bool mgukDeliveryUp; 
  const bool mgukDeliveryDown; 
  const bool mgukRecoveryUp; 
  const bool mgukRecoveryDown; 
  const uint8_t mguhMode; 
  const float gas; 
  const float brake; 
  const float steer; 
  const float clutch; 
} ac_car_controls; ]]

local __rigidbodies = {}
local __rigidbodyCallbacks = {}

---Represents a physics rigid body. Requires double precision physics engine to work.
---@class physics.RigidBody
ffi.metatype('lua_rigidbody', {
  __index = {

    ---Removes rigid body from the world.
    dispose = function (s) 
      table.removeItem(__rigidbodies, s)
      __rigidbodyCallbacks[s.__id] = nil
      __util.__ex.rigidbody_dispose(s)
    end,

    ---Sets collision callback for semidynamic rigid bodies.
    ---@param callback fun()
    ---@return physics.RigidBody @Returns self for easy chaining.
    onCollision = function (s, callback)
      s.__listens_for_collisions = callback ~= nil
      __rigidbodyCallbacks[s.__id] = callback
      return s
    end,
    
    ---@param transform mat4x4
    ---@param estimateVelocity boolean? @Default value: `false`.
    ---@return physics.RigidBody @Returns self for easy chaining.
    setTransformation = function (s, transform, estimateVelocity)
      __util.__ex.rigidbody_settransform(s, __util.ensure_mat4x4(transform), estimateVelocity == true)
      return s
    end,
    
    ---@param sceneReference ac.SceneReference
    ---@param localTransform mat4x4?
    ---@param estimateVelocity boolean? @Default value: `false`.
    ---@return physics.RigidBody @Returns self for easy chaining.
    setTransformationFrom = function (s, sceneReference, localTransform, estimateVelocity)
      __util.__ex.rigidbody_settransformfrom(s, sceneReference, mat4x4.ismat4x4(localTransform) and localTransform or nil, estimateVelocity == true)
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setVelocity = function (s, velocity)
      __util.__ex.rigidbody_setvelocity(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setAngularVelocity = function (s, velocity)
      __util.__ex.rigidbody_setangularvelocity(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param linear number
    ---@param angular number
    ---@return physics.RigidBody @Returns self for easy chaining.
    setDamping = function (s, linear, angular)
      __util.__ex.rigidbody_setdamping(s, tonumber(linear) or 0, tonumber(angular) or 0)
      return s
    end,
    
    ---@param mass number
    ---@return physics.RigidBody @Returns self for easy chaining.
    setMass = function (s, mass)
      __util.__ex.rigidbody_setmass(s, tonumber(mass) or 0)
      return s
    end,

    ---@param value boolean
    ---@param switchBackOnContact boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setSemiDynamic = function (s, value, switchBackOnContact)
      __util.__ex.rigidbody_setsemidynamic(s, value == true, switchBackOnContact == true)
      return s
    end,

    ---@return boolean
    isSemiDynamic = function (s) return __util.__ex.rigidbody_issemidynamic(s) end,

    ---Stops rigidbody, collider is still working.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setEnabled = function (s, value)
      __util.__ex.rigidbody_setenabled(s, value)
      return s
    end,

    ---@return boolean
    isEnabled = function (s) return __util.__ex.rigidbody_isenabled(s) end,
    
    ---Stops rigidbody and removes collider from the world.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setInWorld = function (s, value)
      __util.__ex.rigidbody_setinworld(s, value)
      return s
    end,
    
    ---@return boolean
    isInWorld = function (s) return __util.__ex.rigidbody_isinworld(s) end,

    ---@return number
    getSpeedKmh = function (s) return __util.__ex.rigidbody_getspeedkmh(s) end,
    
    ---@return number
    getAngularSpeed = function (s) return __util.__ex.rigidbody_getangularspeed(s) end,
    
    ---@return vec3
    getVelocity = function (s) return __util.__ex.rigidbody_getvelocity(s) end,

    ---@return vec3
    getAngularVelocity = function (s) return __util.__ex.rigidbody_getangularvelocity(s) end,

    ---@return integer @Wraps to 0 after 255.
    getLastHitIndex = function (s) return __util.__ex.rigidbody_getlasthitindex(s) end,

    ---@return vec3
    getLastHitPos = function (s) return __util.__ex.rigidbody_getlasthitpos(s) end,

    ---@param force vec3
    ---@param forceLocal boolean
    ---@param pos vec3
    ---@param posLocal boolean
    addForce = function (s, force, forceLocal, pos, posLocal) __util.__ex.rigidbody_addforce(s, __util.ensure_vec3(force), forceLocal ~= false, __util.ensure_vec3(pos), posLocal ~= false) end,
    
    ---@param pos vec3
    ---@return vec3
    localPosToWorld = function (s, pos) return __util.__ex.rigidbody_localpostoworld(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    localDirToWorld = function (s, dir) return __util.__ex.rigidbody_localdirtoworld(s, __util.ensure_vec3(dir)) end,

    ---@param pos vec3
    ---@return vec3
    worldPosToLocal = function (s, pos) return __util.__ex.rigidbody_worldpostolocal(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    worldDirToLocal = function (s, dir) return __util.__ex.rigidbody_worlddirtolocal(s, __util.ensure_vec3(dir)) end,
    
    ---@param point vec3
    ---@param pointLocal boolean
    ---@param velocityLocal boolean
    ---@return vec3
    pointVelocity = function (s, point, pointLocal, velocityLocal) return __util.__ex.rigidbody_pointvelocity(s, __util.ensure_vec3(point), pointLocal == true, velocityLocal == true) end,
    
    ---@return mat4x4
    getTransformation = function (s) __util.__ex.rigidbody_gettransform(s) return s.__transform end,
  }
})
function __rigidbodyContact(id)
  local c = __rigidbodyCallbacks[id]
  if c ~= nil then c() end
end

---@alias physics.ColliderType {type: string}

---@param collider string|physics.ColliderType[] @Collider KN5 filename, or a table listing geometric colliders (see `physics.Collider`).
---@param mass number @Mass in kg, can be changed later.
---@param cog vec3? @Center of gravity in collider model, can’t be changed later.
---@param semiDynamic boolean? @Semi-dynamic from the start. Default value: `false`.
---@param startsInWorld boolean? @Add to world from the start. Default value: `true`.
---@return physics.RigidBody
function physics.RigidBody(collider, mass, cog, semiDynamic, startsInWorld)
  local created = __util.__ex.rigidbody_new(type(collider) == 'string', type(collider) == 'string' and collider or __util.json(table.isArray(collider) and collider or {collider}), __util.ensure_vec3(cog))
  if created == nil then error('Not allowed', 2) end
  local ret = ffi.gc(created, __util.__ex.rigidbody_gc)
  table.insert(__rigidbodies, ret)
  if mass ~= nil then ret:setMass(mass) end
  if semiDynamic ~= nil then ret:setSemiDynamic(semiDynamic) end
  if startsInWorld == false then ret:setInWorld(startsInWorld) end
  return ret
end

---Different collider types.
physics.Collider = {}

---Box collider.
---@param size vec3
---@param offset vec3? @Default value: `vec3(0, 0, 0)`.
---@param look vec3? @Default value: `vec3(0, 0, 1)`.
---@param up vec3? @Default value: `vec3(0, 1, 0)`.
---@param debug boolean? @Set to `true` to see an outline. Default value: `false`.
---@return physics.ColliderType
function physics.Collider.Box(size, offset, look, up, debug) return {type = 'box', size = size, offset = offset, look = look, up = up, debug = debug == true} end

---Sphere collider.
---@param radius number
---@param offset vec3? @Default value: `vec3(0, 0, 0)`.
---@param debug boolean? @Set to `true` to see an outline. Default value: `false`.
---@return physics.ColliderType
function physics.Collider.Sphere(radius, offset, debug) return {type = 'sphere', radius = radius, offset = offset, debug = debug == true} end

---Capsule collider (like cylinder, but instead of flat caps it has hemispheres and works a bit faster).
---@param length number
---@param radius number
---@param offset vec3? @Default value: `vec3(0, 0, 0)`.
---@param look vec3? @Default value: `vec3(0, 0, 1)`.
---@param debug boolean? @Set to `true` to see an outline. Default value: `false`.
---@return physics.ColliderType
function physics.Collider.Capsule(length, radius, offset, look, debug) return {type = 'capsule', length = length, radius = radius, offset = offset, look = look, debug = debug == true} end

---Cylinder collider (slower than capsule, consider using capsule where appropriate).
---@param length number
---@param radius number
---@param offset vec3? @Default value: `vec3(0, 0, 0)`.
---@param look vec3? @Default value: `vec3(0, 0, 1)`.
---@param debug boolean? @Set to `true` to see an outline. Default value: `false`.
---@return physics.ColliderType
function physics.Collider.Cylinder(length, radius, offset, look, debug) return {type = 'cylinder', length = length, radius = radius, offset = offset, look = look, debug = debug == true} end
