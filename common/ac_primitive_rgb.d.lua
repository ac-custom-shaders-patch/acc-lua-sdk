---Creates new instance. It’s usually faster to create a new item with `rgb(r, g, b, mult)` directly, but the way LuaJIT works,
---that call only works with three numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
---various calls (which also makes it slightly slower).
---@overload fun(color: rgb): rgb
---@overload fun(color: rgbm): rgb
---@overload fun(color: hsv): rgb
---@overload fun(color: vec4): rgb
---@overload fun(color: vec3): rgb
---@overload fun(tableOfThree: number[]): rgb
---@overload fun(color: number): rgb
---@overload fun(value: string): rgb
---@param r number?
---@param g number?
---@param b number?
---@return rgb
function rgb.new(r, g, b, m) end

---Checks if value is rgb or not.
---@param p any
---@return boolean
function rgb.isrgb(p) end

---Temporary color. For most cases though, it might be better to define those locally and use those. Less chance of collision.
---@return rgb
function rgb.tmp() end

---Creates color from 0…255 values
---@param r number @From 0 to 255
---@param g number @From 0 to 255
---@param b number @From 0 to 255
---@return rgb
function rgb.from0255(r, g, b, a) end

---Predefined colors. Do not change them unless you want to have some extra fun debugging.
rgb.colors = {
  transparent = rgb(0, 0, 0),
  black = rgb(0, 0, 0),
  silver = rgb(0.75, 0.75, 0.75),
  gray = rgb(0.5, 0.5, 0.5),
  white = rgb(1, 1, 1),
  maroon = rgb(0.5, 0, 0),
  red = rgb(1, 0, 0),
  purple = rgb(0.5, 0, 0.5),
  fuchsia = rgb(1, 0, 1),
  green = rgb(0, 0.5, 0),
  lime = rgb(0, 1, 0),
  olive = rgb(0.5, 0.5, 0),
  yellow = rgb(1, 1, 0),
  orange = rgb(1, 0.5, 0),
  navy = rgb(0, 0, 0.5),
  blue = rgb(0, 0, 1),
  teal = rgb(0, 0.5, 0.5),
  cyan = rgb(0, 0.5, 1),
  aqua = rgb(0, 1, 1),
}

---Three-channel color. All operators are overloaded. White is usually `rgb=1,1,1`.
---@class rgb
---@field r number
---@field g number
---@field b number
---@constructor fun(r: number?, g: number?, b: number?): rgb

---Makes a copy of a vector.
---@return rgb
function rgb:clone() end

---Unpacks rgb into three numbers.
---@return rgb, number
function rgb:unpack() end

---Turns rgb into a table with three numbers.
---@return number[]
function rgb:table() end

---Returns reference to rgb class.
function rgb:type() end

---@param r rgb|number
---@param g number?
---@param b number?
---@return rgb @Returns itself.
function rgb:set(r, g, b) end

---@param x rgb
---@param mult number
---@return rgb @Returns itself.
function rgb:setScaled(x, mult) end

---@param value1 rgb
---@param value2 rgb
---@param mix number
---@return rgb @Returns itself.
function rgb:setLerp(value1, value2, mix) end

---@param valueToAdd rgb|number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:add(valueToAdd, out) end

---@param valueToAdd rgb
---@param scale number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:addScaled(valueToAdd, scale, out) end

---@param valueToSubtract rgb|number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:sub(valueToSubtract, out) end

---@param valueToMultiplyBy rgb
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:mul(valueToMultiplyBy, out) end

---@param valueToDivideBy rgb
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:div(valueToDivideBy, out) end

---@param exponent rgb|number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:pow(exponent, out) end

---@param multiplier number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:scale(multiplier, out) end

---@param otherValue rgb|number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:min(otherValue, out) end

---@param otherValue rgb|number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:max(otherValue, out) end

---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:saturate(out) end

---@param min rgb
---@param max rgb
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:clamp(min, max, out) end

---Adjusts saturation using a very simple formula.
---@param saturation number
---@param out rgb|nil @Optional destination argument.
---@return rgb @Returns itself or out value.
function rgb:adjustSaturation(saturation, out) end

---Makes sure brightest value does not exceed 1.
---@return rgb @Returns itself.
function rgb:normalize() end

---Returns brightest value (aka V in HSV).
---@return number
function rgb:value() end

---Returns hue.
---@return number
function rgb:hue() end

---Returns saturation.
---@return number
function rgb:saturation() end

---Returns luminance value.
---@return number
function rgb:luminance() end

---Returns rgbm.
---@param mult number? @Default value: 1.
---@return rgbm
function rgb:rgbm(mult) end

---Returns HSV color of rgb*mult.
---@return hsv
function rgb:hsv() end

---Returns rgb*mult turned to vec3.
---@return vec3
function rgb:vec3() end
