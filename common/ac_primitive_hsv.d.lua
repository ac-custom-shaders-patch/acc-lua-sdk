---Creates new instance. It’s usually faster to create a new item with `hsv(h, s, v)`.
---@param h number?
---@param s number?
---@param v number?
---@return hsv
function hsv.new(h, s, v) end

---Checks if value is hsv or not.
---@param p any
---@return boolean
function hsv.ishsv(p) end

---Temporary HSV color. For most cases though, it might be better to define those locally and use those. Less chance of collision.
---@return hsv
function hsv.tmp() end

---HSV color (hue, saturation, value). Equality operator is overloaded.
---@class hsv
---@field h number
---@field s number
---@field v number
---@constructor fun(h: number?, s: number?, v: number?): hsv

---Makes a copy of a vector.
---@return hsv
function hsv:clone() end

---Unpacks hsv into three numbers.
---@return rgb, number
function hsv:unpack() end

---Turns hsv into a table with three numbers.
---@return number[]
function hsv:table() end

---Returns reference to hsv class.
function hsv:type() end

---@param h number
---@param s number
---@param v number
---@return hsv @Returns itself.
function hsv:set(h, s, v) end

---Returns RGB color.
---@return rgb
function hsv:rgb() end
