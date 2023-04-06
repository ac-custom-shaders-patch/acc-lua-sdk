---Creates new vector. It’s usually faster to create a new item with `vec4(x, y, z, w)` directly, but the way LuaJIT works,
---that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
---various calls (which also makes it slightly slower).
---@overload fun(value: vec4): vec4
---@overload fun(tableOfFour: number[]): vec4
---@overload fun(value: number): vec4
---@overload fun(value: string): vec4
---@param x number?
---@param y number?
---@param z number?
---@param w number?
---@return vec4
function vec4.new(x, y, z, w) end

---Checks if value is vec4 or not.
---@param p any
---@return boolean
function vec4.isvec4(p) end

---Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.
---@return vec4
function vec4.tmp() end

---Four-dimensional vector. All operators are also overloaded.
---Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
---Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
---```
---someVec = vec4()
---…
---someVec = math.normalize(vec1 + vec2) * 10
---```
---Consider rewriting it like:
---```
---someVec = vec4()
---…
---someVec:set(vec1):add(vec2):normalize():scale(10)
---```
---@class vec4
---@field x number
---@field y number
---@field z number
---@field w number
---@operator add(number|vec4): vec4
---@operator sub(number|vec4): vec4
---@operator mul(number|vec4): vec4
---@operator div(number|vec4): vec4
---@operator pow(number|vec4): vec4
---@operator len: number
---@constructor fun(x: number?, y: number?, z: number?, w: number?): vec4

---Makes a copy of a vector.
---@return vec4
function vec4:clone() end

---Unpacks vec4 into rgb and number.
---@return rgb, number
function vec4:unpack() end

---Turns vec4 into a table with four values.
---@return number[]
function vec4:table() end

---Returns reference to vec4 class.
function vec4:type() end

---@param x vec4|number
---@param y number?
---@param z number?
---@param w number?
---@return vec4 @Returns itself.
function vec4:set(x, y, z, w) end

---@param vec vec4
---@param scale number
---@return vec4 @Returns itself.
function vec4:setScaled(vec, scale) end

---@param value1 vec4
---@param value2 vec4
---@param mix number
---@return vec4 @Returns itself.
function vec4:setLerp(value1, value2, mix) end

---Sets itself to a normalized result of cross product of value1 and value2.
---@param value1 vec4
---@param value2 vec4
---@return vec4 @Returns itself.
function vec4:setCrossNormalized(value1, value2) end

---Copies its values to a different vector.
---@param out vec4
---@return vec4 @Returns itself.
function vec4:copyTo(out) end

---@param valueToAdd vec4|number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:add(valueToAdd, out) end

---@param valueToAdd vec4
---@param scale number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:addScaled(valueToAdd, scale, out) end

---@param valueToSubtract vec4|number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:sub(valueToSubtract, out) end

---@param valueToMultiplyBy vec4
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:mul(valueToMultiplyBy, out) end

---@param valueToDivideBy vec4
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:div(valueToDivideBy, out) end

---@param exponent vec4|number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:pow(exponent, out) end

---@param multiplier number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:scale(multiplier, out) end

---@param otherValue vec4|number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:min(otherValue, out) end

---@param otherValue vec4|number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:max(otherValue, out) end

---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:saturate(out) end

---@param min vec4
---@param max vec4
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:clamp(min, max, out) end

---@return number
function vec4:length() end

---@return number
function vec4:lengthSquared() end

---@param otherVector vec4
---@return number
function vec4:distance(otherVector) end

---@param otherVector vec4
---@return number
function vec4:distanceSquared(otherVector) end

---@param otherVector vec4
---@param distanceThreshold number
---@return boolean
function vec4:closerToThan(otherVector, distanceThreshold) end

---@param otherVector vec4
---@return number @Radians.
function vec4:angle(otherVector) end

---@param otherVector vec4
---@return number
function vec4:dot(otherVector) end

---Normalizes itself (unless different `out` is provided).
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:normalize(out) end

---Rewrites own values with values of lerp of itself and other vector (unless different `out` is provided).
---@param otherVector vec4
---@param mix number
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:lerp(otherVector, mix, out) end

---Rewrites own values with values of projection of itself onto another vector (unless different `out` is provided).
---@param otherVector vec4
---@param out vec4|nil @Optional destination argument.
---@return vec4 @Returns itself or out value.
function vec4:project(otherVector, out) end
