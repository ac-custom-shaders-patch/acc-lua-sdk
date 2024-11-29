---Creates new quaternion. It’s usually faster to create a new item with `quat(x, y, z, w)` directly, but the way LuaJIT works,
---that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
---various calls (which also makes it slightly slower).
---@overload fun(value: quat): quat
---@overload fun(tableOfFour: number[]): quat
---@overload fun(value: number): quat
---@param x number?
---@param y number?
---@param z number?
---@param w number?
---@return quat
function quat.new(x, y, z, w) end

---Checks if value is quat or not.
---@param p any
---@return boolean
function quat.isquat(p) end

---Creates a new quaternion.
---@param angle number @In radians.
---@param x vec3|number
---@param y number?
---@param z number?
---@return quat
function quat.fromAngleAxis(angle, x, y, z) end

---Creates a new quaternion.
---@param x vec3|number
---@param y number?
---@param z number?
---@return quat
function quat.fromDirection(x, y, z) end

---Creates a new quaternion.
---@param u quat
---@param v quat
---@return quat
function quat.between(u, v) end

---Temporary quaternion. For most cases though, it might be better to define those locally and use those. Less chance of collision.
---@return quat
function quat.tmp() end

---Quaternion. All operators are overloaded.
---@class quat
---@field x number
---@field y number
---@field z number
---@field w number
---@constructor fun(x: number?, y: number?, z: number?, w: number?): quat

---Makes a copy of a quaternion.
---@return quat
function quat:clone() end

---Unpacks quat into four numbers.
---@return number, number, number, number
function quat:unpack() end

---Turns quat into a table with four values.
---@return number[]
function quat:table() end

---Returns reference to quat class.
function quat:type() end

---@param x quat|number
---@param y number?
---@param z number?
---@param w number?
---@return quat @Returns itself.
function quat:set(x, y, z, w) end

---@param angle number @In radians.
---@param x vec3|number
---@param y number?
---@param z number?
---@return quat @Returns itself.
function quat:setAngleAxis(angle, x, y, z) end

---@return number @Angle in radians.
---@return number @Axis, X.
---@return number @Axis, Y.
---@return number @Axis, Z.
function quat:getAngleAxis() end

---@param u quat
---@param v quat
---@return quat @Returns itself.
function quat:setBetween(u, v) end

---@param x vec3|number
---@param y number?
---@param z number?
---@return quat @Returns itself.
function quat:setDirection(x, y, z) end

---@param valueToAdd quat|number
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:add(valueToAdd, out) end

---@param valueToSubtract quat|number
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:sub(valueToSubtract, out) end

---@param valueToMultiplyBy quat
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:mul(valueToMultiplyBy, out) end

---@param multiplier number
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:scale(multiplier, out) end

---@return number
function quat:length() end

---Normalizes itself (unless different `out` is provided).
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:normalize(out) end

---Rewrites own values with values of lerp of itself and other quaternion (unless different `out` is provided).
---@param otherVector quat
---@param mix number
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:lerp(otherVector, mix, out) end

---Rewrites own values with values of slerp of itself and other quaternion (unless different `out` is provided).
---@param otherVector quat
---@param mix number
---@param out quat|nil @Optional destination argument.
---@return quat @Returns itself or out value.
function quat:slerp(otherVector, mix, out) end
