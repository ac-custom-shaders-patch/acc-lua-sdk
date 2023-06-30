---Creates a new neutral matrix.
---@return mat3x3
function mat3x3.identity() end

---@class mat3x3
---@field row1 vec3
---@field row2 vec3
---@field row3 vec3
---@constructor fun(row1: vec3?, row2: vec3?, row3: vec3?): mat3x3

---@param value mat3x3
---@return mat3x3
function mat3x3:set(value) end

---@return mat3x3
function mat3x3:clone() end

---Creates a new neutral matrix.
---@return mat4x4
function mat4x4.identity() end

---Creates a translation matrix.
---@param offset vec3
---@return mat4x4
function mat4x4.translation(offset) end

---Creates a rotation matrix.
---@param angle number @Angle in radians.
---@param axis vec3
---@return mat4x4
function mat4x4.rotation(angle, axis) end

---Creates a rotation matrix from Euler angles in radians.
---@param head number
---@param pitch number
---@param roll number
---@return mat4x4
function mat4x4.euler(head, pitch, roll) end

---Creates a scaling matrix.
---@param scale vec3
---@return mat4x4
function mat4x4.scaling(scale) end

---@class mat4x4
---@field row1 vec4
---@field row2 vec4
---@field row3 vec4
---@field row4 vec4
---@field position vec3
---@field look vec3
---@field side vec3
---@field up vec3
---@constructor fun(row1: vec4?, row2: vec4?, row3: vec4?, row4: vec4?): mat4x4

---@param value mat4x4
---@return mat4x4
function mat4x4:set(value) end

---@param destination vec3
---@param vec vec3
---@return vec3
function mat4x4:transformVectorTo(destination, vec) end

---@param vec vec3
---@return vec3
function mat4x4:transformVector(vec) end

---@param destination vec3
---@param vec vec3
---@return vec3
function mat4x4:transformPointTo(destination, vec) end

---@param vec vec3
---@return vec3
function mat4x4:transformPoint(vec) end

---@return mat4x4
function mat4x4:clone() end

---Creates a new matrix.
---@return mat4x4
function mat4x4:inverse() end

---Modifies current matrix.
---@return mat4x4 @Returns self for easy chaining.
function mat4x4:inverseSelf() end

---Creates a new matrix.
---@return mat4x4
function mat4x4:normalize() end

---Modifies current matrix.
---@return mat4x4 @Returns self for easy chaining.
function mat4x4:normalizeSelf() end

---Creates a new matrix.
---@return mat4x4
function mat4x4:transpose() end

---Modifies current matrix.
---@return mat4x4 @Returns self for easy chaining.
function mat4x4:transposeSelf() end

---Note: unlike vector’s `:mul()`, this one creates a new matrix!
---@param other mat4x4
---@return mat4x4
function mat4x4:mul(other) end

---Modifies current matrix.
---@param other mat4x4
---@return mat4x4 @Returns self for easy chaining.
function mat4x4:mulSelf(other) end
