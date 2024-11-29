__source 'lua/api_physics.cpp'
__source 'lua/api_physics_raycast.cpp'
__namespace 'physics'

require './ac_ray'

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
      ffi.C.lj_rigidbody_dispose__physics(s)
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
      ffi.C.lj_rigidbody_settransform__physics(s, __util.ensure_mat4x4(transform), estimateVelocity == true)
      return s
    end,
    
    ---@param sceneReference ac.SceneReference
    ---@param localTransform mat4x4?
    ---@param estimateVelocity boolean? @Default value: `false`.
    ---@return physics.RigidBody @Returns self for easy chaining.
    setTransformationFrom = function (s, sceneReference, localTransform, estimateVelocity)
      ffi.C.lj_rigidbody_settransformfrom__physics(s, sceneReference, mat4x4.ismat4x4(localTransform) and localTransform or nil, estimateVelocity == true)
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setVelocity = function (s, velocity)
      ffi.C.lj_rigidbody_setvelocity__physics(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setAngularVelocity = function (s, velocity)
      ffi.C.lj_rigidbody_setangularvelocity__physics(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param linear number
    ---@param angular number
    ---@return physics.RigidBody @Returns self for easy chaining.
    setDamping = function (s, linear, angular)
      ffi.C.lj_rigidbody_setdamping__physics(s, tonumber(linear) or 0, tonumber(angular) or 0)
      return s
    end,
    
    ---@param mass number
    ---@return physics.RigidBody @Returns self for easy chaining.
    setMass = function (s, mass)
      ffi.C.lj_rigidbody_setmass__physics(s, tonumber(mass) or 0)
      return s
    end,

    ---@param value boolean
    ---@param switchBackOnContact boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setSemiDynamic = function (s, value, switchBackOnContact)
      ffi.C.lj_rigidbody_setsemidynamic__physics(s, value == true, switchBackOnContact == true)
      return s
    end,

    ---@return boolean
    isSemiDynamic = function (s) return ffi.C.lj_rigidbody_issemidynamic__physics(s) end,

    ---Stops rigidbody, collider is still working.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setEnabled = function (s, value)
      ffi.C.lj_rigidbody_setenabled__physics(s, value)
      return s
    end,

    ---@return boolean
    isEnabled = function (s) return ffi.C.lj_rigidbody_isenabled__physics(s) end,
    
    ---Stops rigidbody and removes collider from the world.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setInWorld = function (s, value)
      ffi.C.lj_rigidbody_setinworld__physics(s, value)
      return s
    end,
    
    ---@return boolean
    isInWorld = function (s) return ffi.C.lj_rigidbody_isinworld__physics(s) end,

    ---@return number
    getSpeedKmh = function (s) return ffi.C.lj_rigidbody_getspeedkmh__physics(s) end,
    
    ---@return number
    getAngularSpeed = function (s) return ffi.C.lj_rigidbody_getangularspeed__physics(s) end,
    
    ---@return vec3
    getVelocity = function (s) return ffi.C.lj_rigidbody_getvelocity__physics(s) end,

    ---@return vec3
    getAngularVelocity = function (s) return ffi.C.lj_rigidbody_getangularvelocity__physics(s) end,

    ---@return integer @Wraps to 0 after 255.
    getLastHitIndex = function (s) return ffi.C.lj_rigidbody_getlasthitindex__physics(s) end,

    ---@return vec3
    getLastHitPos = function (s) return ffi.C.lj_rigidbody_getlasthitpos__physics(s) end,

    ---@param force vec3
    ---@param forceLocal boolean
    ---@param pos vec3
    ---@param posLocal boolean
    addForce = function (s, force, forceLocal, pos, posLocal) ffi.C.lj_rigidbody_addforce__physics(s, __util.ensure_vec3(force), forceLocal ~= false, __util.ensure_vec3(pos), posLocal ~= false) end,
    
    ---@param pos vec3
    ---@return vec3
    localPosToWorld = function (s, pos) return ffi.C.lj_rigidbody_localpostoworld__physics(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    localDirToWorld = function (s, dir) return ffi.C.lj_rigidbody_localdirtoworld__physics(s, __util.ensure_vec3(dir)) end,

    ---@param pos vec3
    ---@return vec3
    worldPosToLocal = function (s, pos) return ffi.C.lj_rigidbody_worldpostolocal__physics(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    worldDirToLocal = function (s, dir) return ffi.C.lj_rigidbody_worlddirtolocal__physics(s, __util.ensure_vec3(dir)) end,
    
    ---@param point vec3
    ---@param pointLocal boolean
    ---@param velocityLocal boolean
    ---@return vec3
    pointVelocity = function (s, point, pointLocal, velocityLocal) return ffi.C.lj_rigidbody_pointvelocity__physics(s, __util.ensure_vec3(point), pointLocal == true, velocityLocal == true) end,
    
    ---@return mat4x4
    getTransformation = function (s) ffi.C.lj_rigidbody_gettransform__physics(s) return s.__transform end,
  }
})
function __rigidbodyContact(id)
  local c = __rigidbodyCallbacks[id]
  if c ~= nil then c() end
end

---@alias physics.ColliderType {type: string}

---@param collider string|{filename: string, filter: string, debug: boolean?, transform: boolean?}|physics.ColliderType[] @Collider KN5 filename (or a table with filename and mesh filter, available since CSP 0.2.5 (set `transform` to `true` to use transform from the KN5); only the first matching mesh will be used, with or without filter), or a table listing geometric colliders (see `physics.Collider`).
---@param mass number @Mass in kg, can be changed later.
---@param cog vec3? @Center of gravity in collider model, can’t be changed later.
---@param semiDynamic boolean? @Semi-dynamic from the start. Default value: `false`.
---@param startsInWorld boolean? @Add to world from the start. Default value: `true`.
---@return physics.RigidBody
function physics.RigidBody(collider, mass, cog, semiDynamic, startsInWorld)
  local meshFilter
  local meshFlags = 0
  if type(collider) == 'table' and collider.filename then
    meshFilter = collider.filter and tostring(collider.filter) or nil
    if collider.debug then meshFlags = meshFlags + 1 end
    if collider.transform then meshFlags = meshFlags + 2 end
    collider = tostring(collider.filename)
  end
  local created = ffi.C.lj_rigidbody_new__physics(type(collider) == 'string', type(collider) == 'string' and collider or __util.json(table.isArray(collider) and collider or {collider}), meshFilter, meshFlags, __util.ensure_vec3(cog))
  if created == nil then error('Not allowed', 2) end
  local ret = ffi.gc(created, ffi.C.lj_rigidbody_gc__physics)
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

