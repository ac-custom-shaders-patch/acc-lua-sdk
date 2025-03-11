---@param data string @String with LUT data, in a format similar to AC LUT formats. Please note: rows must be ordered for efficient binary search.
---@param hsvColumns integer[] @1-based indices of columns storing HSV data. Such columns, of course, will be interpolated differently (for example, mixing hues 350 and 20 would produce 10).
---@return ac.Lut
function ac.Lut(data, hsvColumns)
  return __util.lazy('lib_numlut')(data, hsvColumns)
end

---@type ac.Lut
ac.LutCpp = ac.Lut

ac.LutJit = {}

---Creates new ac.LuaJit instance. Deprecated and broken, use `ac.Lut` instead.
---@deprecated
---@param data any
---@param hsvRows integer[] @ 1-based indices of columns (not rows) storing HSV values in them.
---@return table
function ac.LutJit:new(o, data, hsvRows)
  return __util.lazy('lib_numlut_jit'):new(o, data, hsvRows)
end
