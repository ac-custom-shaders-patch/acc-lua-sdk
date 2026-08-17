__source 'lua/api_physics.cpp'
__namespace 'physicslib'

ffi.cdef [[ typedef struct { int __id; bool __listens_for_collisions; mat4x4 __transform; } lua_rigidbody; ]]

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
      ffi.C.lj_rigidbody_dispose__physicslib(s)
    end,

    ---Sets collision callback. Can’t be triggered more than once per graphics frame.
    ---@param callback fun(carIndex: integer?) @If collided with a car, receives a 0-based car index. If collided with two or more cars in a single graphics frame, returns the index of the first car.
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
      ffi.C.lj_rigidbody_settransform__physicslib(s, __util.ensure_mat4x4(transform), estimateVelocity == true)
      return s
    end,
    
    ---@param sceneReference ac.SceneReference
    ---@param localTransform mat4x4?
    ---@param estimateVelocity boolean? @Default value: `false`.
    ---@return physics.RigidBody @Returns self for easy chaining.
    setTransformationFrom = function (s, sceneReference, localTransform, estimateVelocity)
      ffi.C.lj_rigidbody_settransformfrom__physicslib(s, sceneReference, mat4x4.ismat4x4(localTransform) and localTransform or nil, estimateVelocity == true)
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setVelocity = function (s, velocity)
      ffi.C.lj_rigidbody_setvelocity__physicslib(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param velocity vec3
    ---@return physics.RigidBody @Returns self for easy chaining.
    setAngularVelocity = function (s, velocity)
      ffi.C.lj_rigidbody_setangularvelocity__physicslib(s, __util.ensure_vec3(velocity))
      return s
    end,

    ---@param linear number
    ---@param angular number
    ---@param applyToAll boolean @Set to `true` to get the function to work properly (added for backwards compatibility).
    ---@return physics.RigidBody @Returns self for easy chaining.
    setDamping = function (s, linear, angular, applyToAll)
      ffi.C.lj_rigidbody_setdamping__physicslib(s, tonumber(linear) or 0, tonumber(angular) or 0, applyToAll == true)
      return s
    end,
    
    ---@param mass number
    ---@return physics.RigidBody @Returns self for easy chaining.
    setMass = function (s, mass)
      ffi.C.lj_rigidbody_setmass__physicslib(s, tonumber(mass) or 0)
      return s
    end,

    ---@param value boolean
    ---@param switchBackOnContact boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setSemiDynamic = function (s, value, switchBackOnContact)
      ffi.C.lj_rigidbody_setsemidynamic__physicslib(s, value == true, switchBackOnContact == true)
      return s
    end,

    ---@return boolean
    isSemiDynamic = function (s) return ffi.C.lj_rigidbody_issemidynamic__physicslib(s) end,

    ---Stops rigidbody, collider is still working.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setEnabled = function (s, value)
      ffi.C.lj_rigidbody_setenabled__physicslib(s, value)
      return s
    end,

    ---@return boolean
    isEnabled = function (s) return ffi.C.lj_rigidbody_isenabled__physicslib(s) end,
    
    ---Stops rigidbody and removes collider from the world.
    ---@param value boolean
    ---@return physics.RigidBody @Returns self for easy chaining.
    setInWorld = function (s, value)
      ffi.C.lj_rigidbody_setinworld__physicslib(s, value)
      return s
    end,
    
    ---@return boolean
    isInWorld = function (s) return ffi.C.lj_rigidbody_isinworld__physicslib(s) end,

    ---@return number
    getSpeedKmh = function (s) return ffi.C.lj_rigidbody_getspeedkmh__physicslib(s) end,
    
    ---@return number
    getAngularSpeed = function (s) return ffi.C.lj_rigidbody_getangularspeed__physicslib(s) end,
    
    ---@return vec3
    getVelocity = function (s) return ffi.C.lj_rigidbody_getvelocity__physicslib(s) end,

    ---@return vec3
    getAngularVelocity = function (s) return ffi.C.lj_rigidbody_getangularvelocity__physicslib(s) end,

    ---@return integer @Wraps to 0 after 255.
    getLastHitIndex = function (s) return ffi.C.lj_rigidbody_getlasthitindex__physicslib(s) end,

    ---@return vec3
    getLastHitPos = function (s) return ffi.C.lj_rigidbody_getlasthitpos__physicslib(s) end,

    ---@param force vec3
    ---@param forceLocal boolean
    ---@param pos vec3
    ---@param posLocal boolean
    addForce = function (s, force, forceLocal, pos, posLocal) ffi.C.lj_rigidbody_addforce__physicslib(s, __util.ensure_vec3(force), forceLocal ~= false, __util.ensure_vec3(pos), posLocal ~= false) end,
    
    ---@param pos vec3
    ---@return vec3
    localPosToWorld = function (s, pos) return ffi.C.lj_rigidbody_localpostoworld__physicslib(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    localDirToWorld = function (s, dir) return ffi.C.lj_rigidbody_localdirtoworld__physicslib(s, __util.ensure_vec3(dir)) end,

    ---@param pos vec3
    ---@return vec3
    worldPosToLocal = function (s, pos) return ffi.C.lj_rigidbody_worldpostolocal__physicslib(s, __util.ensure_vec3(pos)) end,

    ---@param dir vec3
    ---@return vec3
    worldDirToLocal = function (s, dir) return ffi.C.lj_rigidbody_worlddirtolocal__physicslib(s, __util.ensure_vec3(dir)) end,
    
    ---@param point vec3
    ---@param pointLocal boolean
    ---@param velocityLocal boolean
    ---@return vec3
    pointVelocity = function (s, point, pointLocal, velocityLocal) return ffi.C.lj_rigidbody_pointvelocity__physicslib(s, __util.ensure_vec3(point), pointLocal == true, velocityLocal == true) end,
    
    ---@return mat4x4
    getTransformation = function (s) ffi.C.lj_rigidbody_gettransform__physicslib(s) return s.__transform end,
  }
})
function __rigidbodyContact(id, carIndex)
  local c = __rigidbodyCallbacks[id]
  if c ~= nil then c(carIndex >= 0 and carIndex or nil) end
end

---Create a new physics rigidbody with a collider (could be a mesh from KN5 or one or several geometric colliders). It’s up to your code to
---keep track of rigidbody transform and assign it to something visual.
---
---Example (link to “cone.kn5”: https://files.acstuff.club/VmRC/cone.kn5; note how single KN5 stores both visuals and a collider mesh):
---```
---local targetRoot = ac.findNodes('dynamicRoot:yes')
---local loadedModel = targetRoot:loadKN5({filename = 'cone.kn5', filter = 'mesh'})
---local physics = physics.RigidBody({
---  filename = 'cone.kn5',
---  filter = 'collider',
---  debug = true,
---  transform = true
---}, 10)
---physics:setSemiDynamic(true, true)
---physics:setTransformation(mat4x4.translation(vec3(-2679.85, -41.06, -202.68)))
---setInterval(function ()
---  loadedModel:setTransformationFrom(physics)
---end)
---```
---
---By default spawened bodies have a bit of a damping. Use `:setDamping()` to remove it.
---@param collider string|{filename: string, filter: string, debug: boolean?, transform: boolean?}|physics.ColliderType[] @Collider KN5 filename (or a table with filename and mesh filter, available since CSP 0.2.5 (set `transform` to `true` to use transform from the KN5); only the first matching mesh will be used, with or without filter), or a table listing geometric colliders (see `physics.Collider`).
---@param mass number @Mass in kg, can be changed later.
---@param cog vec3? @Center of gravity in collider model, can’t be changed later.
---@param semiDynamic boolean? @Semi-dynamic from the start. Semi-dynamic bodies by default don’t move or collide with each other (and, in a way, not a real physics body), but once touched, become real (that’s how CSP traffic’s collisions are set up: a script creates a few rigid bodies and simply assigns them transforms of nearby cars while in semi-dynamic mode; once touched, those bodies come alive and start moving their cars instead of being moved). Default value: `false`.
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
  local created = __util.native('lj_rigidbody_new__physicslib', type(collider) == 'string', type(collider) == 'string' and collider or __util.json(table.isArray(collider) and collider or {collider}), meshFilter, meshFlags, __util.ensure_vec3(cog))
  if created == nil then error('Not allowed', 2) end
  local ret = ffi.gc(created, ffi.C.lj_rigidbody_gc__physicslib)
  table.insert(__rigidbodies, ret)
  if mass ~= nil then ret:setMass(mass) end
  if semiDynamic ~= nil then ret:setSemiDynamic(semiDynamic) end
  if startsInWorld == false then ret:setInWorld(startsInWorld) end
  return ret
end

---Create a new track physics mesh (could be a wall or a road). Requires AC to use Embree for raycasting (default settings). Currently, causes a huge lag, working on solving the problem. Not available to scripts without Physics API access.
---@param vertices vec3[]|binary @Vector with `vec3` (not `ac.MeshVertex`! Physics doesn’t need all that data), or a binary array.
---@param indices integer[]|binary @Vector with integers for 0-based indices creating the triangles, or a binary array.
---@param surfaceName string? @Default value: 'WALL'
---@param transform mat4x4? @Optional transformation matrix.
---@param debugColor rgbm? @Pass a color to see an outline of the spawned surface.
---@return ac.Disposable
function physics.addTrackSurface(vertices, indices, surfaceName, transform, debugColor)
  if type(vertices) == 'table' and table.isArray(vertices) and vec3.isvec3(vertices[1]) then
    local verticesBuffer = __util.lazy('lib_binary').writeData((#vertices + 1) * 12)
    for i = next(vertices) or 1, #vertices do
      verticesBuffer:vec3(vertices[i])
    end
    vertices = verticesBuffer
  end
  if type(indices) == 'table' and table.isArray(indices) and type(indices[1]) == 'number' then
    local indicesBuffer = __util.lazy('lib_binary').writeData((#indices + 1) * 2)
    for i = next(indices) or 1, #indices do
      indicesBuffer:uint16(indices[i])
    end
    indices = indicesBuffer
  end
  return __util.native('__tmp_addPhysicsMesh2', __util.blob(vertices), __util.blob(indices), surfaceName and tostring(surfaceName) or 'WALL', 
    transform and __util.ensure_mat4x4(transform) or nil, debugColor and __util.ensure_rgbm(debugColor) or nil)
end

__definitions()