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

local __rigidbodies = {}
local __rigidbodyCallbacks = {}

---Represents a physics rigid body. Requires double precision physics engine to work.
---@class physics.RigidBody
ffi.cdef [[ typedef struct { int __id; bool __listens_for_collisions; mat4x4 __transform; } rigidbody; ]]
ffi.metatype('rigidbody', {
  __index = {

    ---Removes rigid body from the world.
    dispose = function (s) 
      table.removeItem(__rigidbodies, s)
      __rigidbodyCallbacks[s.__id] = nil
      ffi.C.lj_rigidbody_dispose__physics(s)
    end,

    ---Sets collision callback for semidynamic rigid bodies.
    ---@param callback fun()
    onCollision = function (s, callback)
      s.__listens_for_collisions = callback ~= nil
      __rigidbodyCallbacks[s.__id] = callback
    end,
    
    ---@param transform mat4x4
    ---@param estimateVelocity boolean
    setTransformation = function (s, transform, estimateVelocity) ffi.C.lj_rigidbody_settransform__physics(s, __util.ensure_mat4x4(transform), estimateVelocity == true) end,

    ---@param velocity vec3
    setVelocity = function (s, velocity) ffi.C.lj_rigidbody_setvelocity__physics(s, __util.ensure_vec3(velocity)) end,

    ---@param velocity vec3
    setAngularVelocity = function (s, velocity) ffi.C.lj_rigidbody_setangularvelocity__physics(s, __util.ensure_vec3(velocity)) end,

    ---@param linear number
    ---@param angular number
    setDamping = function (s, linear, angular) ffi.C.lj_rigidbody_setdamping__physics(s, tonumber(linear) or 0, tonumber(angular) or 0) end,
    
    ---@param mass number
    setMass = function (s, mass) ffi.C.lj_rigidbody_setmass__physics(s, tonumber(mass) or 0) end,

    ---@param value boolean
    ---@param switchBackOnContact boolean
    setSemiDynamic = function (s, value, switchBackOnContact) ffi.C.lj_rigidbody_setsemidynamic__physics(s, value == true, switchBackOnContact == true) end,

    ---@return boolean
    isSemiDynamic = function (s) return ffi.C.lj_rigidbody_issemidynamic__physics(s) end,

    ---Stops rigidbody, collider is still working.
    ---@param value boolean
    setEnabled = function (s, value) ffi.C.lj_rigidbody_setenabled__physics(s, value) end,

    ---@return boolean
    isEnabled = function (s) return ffi.C.lj_rigidbody_isenabled__physics(s) end,
    
    ---Stops rigidbody and removes collider from the world.
    ---@param value boolean
    setInWorld = function (s, value) ffi.C.lj_rigidbody_setinworld__physics(s, value) end,
    
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

---@param filename string @Collider KN5 filename.
---@param mass number @Mass in kg, can be changed later.
---@param cog vec3 @Center of gravity in collider model, can’t be changed later.
---@param semiDynamic boolean @Semi-dynamic from the start. Default value: `false`.
---@param startsInWorld boolean @Add to world from the start. Default value: `true`.
---@return physics.RigidBody
function physics.RigidBody(filename, mass, cog, semiDynamic, startsInWorld)
  local created = ffi.C.lj_rigidbody_new__physics(filename, __util.ensure_vec3(cog))
  if created == nil then error('Not allowed', 2) end
  local ret = ffi.gc(created, ffi.C.lj_rigidbody_gc__physics)
  table.insert(__rigidbodies, ret)
  if mass ~= nil then ret:setMass(mass) end
  if semiDynamic ~= nil then ret:setSemiDynamic(semiDynamic) end
  if startsInWorld == false then ret:setInWorld(startsInWorld) end
  return ret
end
