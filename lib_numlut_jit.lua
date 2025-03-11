require './common/internal_import'

-- Obsolete LuaJIT-only implementation
local LuaJit_rgb = rgb()
local LuaJit_hsv = hsv()
local function LuaJit_rgbToHsv(data, i)
  LuaJit_rgb.r = data[i]
  LuaJit_rgb.g = data[i + 1]
  LuaJit_rgb.b = data[i + 2]
  data[i] = LuaJit_rgb:hue()
  data[i + 1] = LuaJit_rgb:saturation()
  data[i + 2] = LuaJit_rgb:value()
end
local function LuaJit_hsvToRgb(data, i)
  LuaJit_hsv.h = data[i]
  LuaJit_hsv.s = data[i + 1]
  LuaJit_hsv.v = data[i + 2]
  local r = LuaJit_hsv:rgb()
  data[i] = r.r
  data[i + 1] = r.g
  data[i + 2] = r.b
end
local function LuaJit_prepareData(data, rows, hsvRows)
  local hsvCount = #hsvRows
  for i = 1, rows do
    for j = 1, hsvCount do
      LuaJit_hsvToRgb(data[i].output, hsvRows[j])
    end
  end
end
local function LutJit_findLeft(rows, count_base, input)
  local count_search = count_base;
  local index = 0
  while count_search > 0 do
    local step = math.floor(count_search / 2)
    if rows[index + step + 1].input > input then
      count_search = step;
    else
      index = index + step + 1;
      count_search = count_search - step + 1;
    end
  end
  return rows[index > 0 and index or 1], rows[index < count_base and index + 1 or index]
end
local function LutJit_distanceToDiv(next, previous)
  return math.max(next.input - previous.input, 0.0000001)
end
local function LutJit_finalize(self, data)
  for i = 1, #self.hsvRows do
    LuaJit_rgbToHsv(data, self.hsvRows[i])
  end
end
local function LutJit_setSingle(self, output, item)
  for i = 1, self.columns do
    output[i] = item.output[i]
  end
  LutJit_finalize(self, output)
end
local function LutJit_setLerp(self, output, a, b, interpolation)
  for i = 1, self.columns do
    output[i] = math.lerp(a.output[i], b.output[i], interpolation)
  end
  LutJit_finalize(self, output)
end

---Meant to quickly interpolate between tables of values, some of them could be colors set in HSV. Example:
---```
---local lutJit = ac.LutJit:new{ data = {
---  { input = -100, output = {  0.00,   350,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
---  { input =  -90, output = {  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
---  { input =  -20, output = {  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
---  }, hsvRows = { 2 }}
---assert(lutJit:calculate(-95)[1] == 1)
---```
---Obsolete. Use `ac.Lut` instead, with faster C++ implementation.
---@class ac.LutJit
---@deprecated
ac.LutJit = {}

---Creates new ac.LuaJit instance. Deprecated, use `ac.Lut` instead.
---@deprecated
---@param data any
---@param hsvRows integer[] @ 1-based indices of columns (not rows) storing HSV values in them.
---@return table
function ac.LutJit:new(o, data, hsvRows)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.data = o.data or data
  o.hsvRows = o.hsvRows or hsvRows or {}
  o.rows = #o.data
  o.columns = o.rows > 0 and #o.data[1].output or 0
  LuaJit_prepareData(o.data, o.rows, o.hsvRows)
  return o
end

---Computes a new value. Deprecated, use `ac.Lut` instead.
---@deprecated
---@param input number
---@return number[]
function ac.LutJit:calculate(input)
  local ret = {}
  self:calculateTo(ret, input)
  return ret
end

---Computes a new value to a preexisting HSV value. Deprecated, use `ac.Lut` instead.
---@deprecated
---@param output number[]
---@param input number
---@return number[] @Same table as was provided in arguments.
function ac.LutJit:calculateTo(output, input)
  if self.rows == 0 then return {} end

  local previous, next = LutJit_findLeft(self.data, self.rows, input);
  if next.input == previous.input then
    LutJit_setSingle(self, output, next)
  else
    local interpolation = math.max(input - previous.input, 0) / LutJit_distanceToDiv(next, previous);
    LutJit_setLerp(self, output, previous, next, math.saturate(interpolation));
  end
  return output
end

__definitions()

return ac.LutJit