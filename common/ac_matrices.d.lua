---Creates a new neutral matrix.
---@return mat3x3
function mat3x3.identity() end

---@class mat3x3
---@field row1 vec3
---@field row2 vec3
---@field row3 vec3
---@constructor fun(row1: vec3, row2: vec3, row3: vec3): mat3x3

---@param value mat3x3
---@return mat3x3
function mat3x3:set(value) end

---@return mat3x3
function mat3x3:clone() end

---Creates a new neutral matrix.
---@return mat4x4
function mat4x4.identity() end

---@class mat4x4
---@field row1 vec4
---@field row2 vec4
---@field row3 vec4
---@field row4 vec4
---@field position vec3
---@field look vec3
---@field side vec3
---@field up vec3
---@constructor fun(row1: vec4, row2: vec4, row3: vec4, row4: vec4): mat4x4

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
