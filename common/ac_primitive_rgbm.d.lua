---Creates new instance. It’s usually faster to create a new item with `rgbm(r, g, b, mult)` directly, but the way LuaJIT works,
---that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
---various calls (which also makes it slightly slower).
---@overload fun(color: rgbm): rgbm
---@overload fun(color: rgb): rgbm
---@overload fun(color: hsv): rgbm
---@overload fun(color: vec4): rgbm
---@overload fun(color: vec3): rgbm
---@overload fun(tableOfFour: number[]): rgbm
---@overload fun(hexColor: string): rgbm
---@overload fun(colorAlpha: number): rgbm
---@overload fun(color: number, alpha: number): rgbm
---@param r number?
---@param g number?
---@param b number?
---@param m number? @Default value: 1.
---@return rgbm
function rgbm.new(r, g, b, m) end

---Checks if value is rgbm or not.
---@param p any
---@return boolean
function rgbm.isrgbm(p) end

---Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.
---@return rgbm
function rgbm.tmp() end

---Creates color from 0…255 values
---@param r number @From 0 to 255.
---@param g number @From 0 to 255.
---@param b number @From 0 to 255.
---@param a number? @From 0 to 1. Default value: 1.
---@return rgbm
function rgbm.from0255(r, g, b, a) end

---Predefined colors. Do not change them unless you want to have some extra fun debugging.
rgbm.colors = {
  transparent = rgbm(0, 0, 0, 0),
  black = rgbm(0, 0, 0, 1),
  silver = rgbm(0.75, 0.75, 0.75, 1),
  gray = rgbm(0.5, 0.5, 0.5, 1),
  white = rgbm(1, 1, 1, 1),
  maroon = rgbm(0.5, 0, 0, 1),
  red = rgbm(1, 0, 0, 1),
  purple = rgbm(0.5, 0, 0.5, 1),
  fuchsia = rgbm(1, 0, 1, 1),
  green = rgbm(0, 0.5, 0, 1),
  lime = rgbm(0, 1, 0, 1),
  olive = rgbm(0.5, 0.5, 0, 1),
  yellow = rgbm(1, 1, 0, 1),
  orange = rgbm(1, 0.5, 0, 1),
  navy = rgbm(0, 0, 0.5, 1),
  blue = rgbm(0, 0, 1, 1),
  teal = rgbm(0, 0.5, 0.5, 1),
  cyan = rgbm(0, 0.5, 1, 1),
  aqua = rgbm(0, 1, 1, 1),
}

---Four-channel color. Fourth value, `mult`, can be used for alpha, for brightness, anything like that. All operators are also 
---overloaded. White is usually `rgb=1,1,1`.
---@class rgbm
---@field r number
---@field g number
---@field b number
---@field rgb rgb
---@field mult number
---@constructor fun(r: number?, g: number?, b: number?, mult: number?): rgbm

---Makes a copy of a vector.
---@return rgbm
function rgbm:clone() end

---Unpacks rgbm into rgb and number.
---@return rgb, number
function rgbm:unpack() end

---Turns rgbm into a table with four values.
---@return number[]
function rgbm:table() end

---Returns reference to rgbm class.
function rgbm:type() end

---@param rgb rgbm|rgb
---@param mult number?
---@return rgbm @Returns itself.
function rgbm:set(rgb, mult) end

---@param value1 rgbm
---@param value2 rgbm
---@param mix number
---@return rgbm @Returns itself.
function rgbm:setLerp(value1, value2, mix) end

---@param valueToAdd rgbm|number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:add(valueToAdd, out) end

---@param valueToAdd rgbm
---@param scale number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:addScaled(valueToAdd, scale, out) end

---@param valueToSubtract rgbm|number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:sub(valueToSubtract, out) end

---@param valueToMultiplyBy rgbm
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:mul(valueToMultiplyBy, out) end

---@param valueToDivideBy rgbm
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:div(valueToDivideBy, out) end

---@param exponent rgbm|number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:pow(exponent, out) end

---@param multiplier number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:scale(multiplier, out) end

---@param otherValue rgbm|number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:min(otherValue, out) end

---@param otherValue rgbm|number
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:max(otherValue, out) end

---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:saturate(out) end

---@param min rgbm
---@param max rgbm
---@param out rgbm|nil @Optional destination argument.
---@return rgbm @Returns itself or out value.
function rgbm:clamp(min, max, out) end

---Makes sure brightest value does not exceed 1.
---@return rgbm @Returns itself.
function rgbm:normalize() end

---Returns brightest value.
---@return number
function rgbm:value() end

---Returns luminance value.
---@return number
function rgbm:luminance() end

---Returns color (rgb*mult).
---@return rgb
function rgbm:color() end

---Returns HSV color of rgb*mult.
---@return hsv
function rgbm:hsv() end

---Returns rgb*mult turned to vec3.
---@return vec3
function rgbm:vec3() end

---Returns vec4, where X, Y and Z are RGB values and W is mult.
---@return vec4
function rgbm:vec4() end