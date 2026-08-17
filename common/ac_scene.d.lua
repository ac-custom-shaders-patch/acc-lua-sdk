--[[? if (ctx.flags.withPhysics) out(]]

---Sets object transformation to match transformation of a `physics.RigidBody` instance. If this object is within another object with non-identity transformation,
---it will be taken into account.
---
---There is also a method `physics.RigidBody:setTransformationFrom()` doing the opposite (and requiring an inverse of this matrix).
---@param rigidBody physics.RigidBody @Physics entity to sync transformation with.
---@param localTransform mat4x4? @Optional transformation of scene reference nodes relative to the physics entity.
---@return physics.RigidBody @Returns self for easy chaining.
function _ac_SceneReference:setTransformationFrom(rigidBody, localTransform) end

--[[) ?]]