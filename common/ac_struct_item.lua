local _mmax = math.max
local _mmin = math.min

---Helper to define structures in a safe and secure manner. Create a new table and use values returned
---by these methods as values and pass it to `ac.connect()` or `ac.registerOnlineMessageType()`.
---
---Few notes:
---- Don’t worry about order, elements will be reordered automatically (also, if using associative table
---  in Lua, order would not be strictly defined anyway);
---- If you want to make sure to avoid possible collisions (those functions use format of layout for identifying
---  structures and establishing connections), use `ac.StructItem.key('myOwnUniqueThing')`;
---- If you want to save space (for example, with online messages), there are virtual types `.norm…` and `.unorm…`
---  which would give you floating point values from -1 to 1 (or for 0 to 1 for .unorm… variants), but use 8-bit
---  and 16-bit values for storing, they could help. Also make sure to limit capacity of your strings as much as
---  possible;
---- When accessing string, its checksum will be calculated and compared with checksum of previously accessed value,
---  thus avoiding creating new entities when unnecessary. While it helps with GC, it could incur some overhead
---  on accessing values, so if you need to access string numerous times (let’s say, in a loop), consider copying
---  a reference to it locally.
ac.StructItem = {}

---@return nil
function ac.StructItem.key(key) return {key = tostring(key)} end

---@return number
function ac.StructItem.float() return 1.5 end

---@return number
function ac.StructItem.double() return 2.5 end

---@return number
function ac.StructItem.norm8() return -0.08 end

---@return number
function ac.StructItem.unorm8() return 0.08 end

---@return number
function ac.StructItem.norm16() return -0.16 end

---@return number
function ac.StructItem.unorm16() return 0.16 end

---@return integer
function ac.StructItem.int16() return -16 end

---@return integer
function ac.StructItem.uint16() return 16 end

---@return integer
function ac.StructItem.int32() return -32 end

---@return integer
function ac.StructItem.uint32() return 32 end

---@return integer
function ac.StructItem.int64() return -64 end

---@return integer
function ac.StructItem.uint64() return 64 end

---@return boolean
function ac.StructItem.boolean() return true end

---@return integer
function ac.StructItem.char() return -1 end

---@return integer
function ac.StructItem.byte() return 1 end

---@return vec2
function ac.StructItem.vec2() return vec2.tmp() end

---@return vec3
function ac.StructItem.vec3() return vec3.tmp() end

---@return vec4
function ac.StructItem.vec4() return vec4.tmp() end

---@return rgb
function ac.StructItem.rgb() return rgb.tmp() end

---@return rgbm
function ac.StructItem.rgbm() return rgbm.tmp() end

---@return hsv
function ac.StructItem.hsv() return hsv.tmp() end

---@return quat
function ac.StructItem.quat() return quat.tmp() end

---@generic T
---@param elementType T
---@param size integer
---@return T[]
function ac.StructItem.array(elementType, size)
  if type(elementType) == 'string' then error('Can’t have an array of strings', 2) end
  if type(elementType) == 'table' then error('Can’t have an array of arrays or special types', 2) end
  return { array = size, elementType }
end

---@return string
function ac.StructItem.string(capacity) return tostring(capacity or 32) end

local __slTypes = {
  [-0.08] = { 'int8_t %s;', 1, function (v) return v / 127 end, function (v) return _mmax(_mmin(v, 1), -1) * 127 end },
  [0.08] = { 'uint8_t %s;', 1, function (v) return v / 255 end, function (v) return _mmax(_mmin(v, 1), 0) * 255 end },
  [-0.16] = { 'int16_t %s;', 2, function (v) return v / 32767 end, function (v) return _mmax(_mmin(v, 1), -1) * 32767 end },
  [0.16] = { 'uint16_t %s;', 2, function (v) return v / 65535 end, function (v) return _mmax(_mmin(v, 1), 0) * 65535 end },
  [1.5] = { 'float %s;', 4 },
  [2.5] = { 'double %s;', 8 },
  [-1] = { 'char %s;', 1 },
  [1] = { 'uint8_t %s;', 1 },
  [-8] = { 'int8_t %s;', 1 },
  [8] = { 'uint8_t %s;', 1 },
  [-16] = { 'int16_t %s;', 2 },
  [16] = { 'uint16_t %s;', 2 },
  [-32] = { 'int %s;', 4 },
  [32] = { 'uint %s;', 4 },
  [-64] = { 'int64_t %s;', 8 },
  [64] = { 'uint64_t %s;', 8 },
  [true] = { 'bool %s;', 1 },
  [vec2.tmp()] = { 'vec2 %s;', 8 },
  [vec3.tmp()] = { 'vec3 %s;', 12 },
  [vec4.tmp()] = { 'vec4 %s;', 16 },
  [rgb.tmp()] = { 'rgb %s;', 12 },
  [rgbm.tmp()] = { 'rgbm %s;', 16 },
  [hsv.tmp()] = { 'hsv %s;', 12 },
  [quat.tmp()] = { 'quat %s;', 16 },
  ['string'] = { 
    function(def) return string.format('char %%s[%d];', tonumber(def) or error('Incorrect type: '..def, 2)) end,
    function(def) return -tonumber(def) or error('Incorrect type: '..def, 2) end,
    function(def) 
      local n = tonumber(def) or error('Incorrect type: '..def, 2)      
      return function(v) return __util.ffistrsafe(v, n) end
    end,
    false,
    function(def) 
      local n = tonumber(def) or error('Incorrect type: '..def, 2)
      return function(v) return __util.ffistrhash(v, n) end
    end,
  }
}

local function __slGet(value, col)
  local t = __slTypes[value]
  if t then return t[col] end
  t = __slTypes[type(value)]
  if t then return t[col] and t[col](value) end
end

local function __slType(value)
  return __slGet(value, 1) or error('Unknown type: '..value, 2)
end

local function __slSize(value)
  return __slGet(value, 2) or error('Unknown type: '..value, 2)
end

function __slProxy(value)
  return __slGet(value, 3) or false, __slGet(value, 4) or false, __slGet(value, 5) or false
end

function ac.StructItem.__build(items)
  if type(items) == 'string' then return items end
  if type(items) ~= 'table' or table.isArray(items) then
    error('Associative table is required', 2)
  end
  local key = nil
  local ordered = table.map(items, function (item, index)
    if type(item) == 'table' then
      if item.key then
        key = tostring(item.key)
      elseif item.array then
        return { name = index, type = __slType(item[1]), array = item.array, size = __slSize(item[1]) }
      end
    else
      return { name = index, type = __slType(item), size = __slSize(item) }
    end
  end)
  table.sort(ordered, function (a, b)
    if a.size ~= b.size then return a.size > b.size end
    return a.name < b.name
  end)
  local reordered, i, c, pos = {}, 1, #ordered, 0
  while i <= c do
    if ordered[i] ~= nil then
      local v, l = ordered[i], 8 - pos % 8
      if v.size > 1 and v.size <= 8 and l < v.size then
        for j = i + 1, c do
          if ordered[j] ~= nil and ordered[j].size > 0 and ordered[j].size <= l then
            v, i, ordered[j] = ordered[j], i - 1, nil
            break
          end
        end
      end
      table.insert(reordered, v)
      pos = pos + v.size
    end
    i = i + 1
  end
  local prepared = table.map(reordered, function(item) 
    if item.array then return string.format(item.type, item.name..'['..item.array..']') end
    return string.format(item.type, item.name) 
  end)
  if key then table.insert(prepared, '//'..tostring(key)) end
  return table.concat(prepared)
end

function ac.StructItem.__cdef(name, layout, compact)
  return string.format(compact 
    and '#pragma pack(push, 1)\ntypedef struct {\n%s\n} %s;\n#pragma pack(pop)' 
    or 'typedef struct {\n%s\n} %s;', ac.StructItem.__build(layout), name)
end

local __slProxyMt = { 
  __index = function (s, k)
    if k == '__stringify' then return end
    s = s.__data
    local r, v = s.p.r[k], s.i[k]
    if not r then return v end
    return r(v)
  end,
  __newindex = function (s, k, v)
    s = s.__data
    local w = s.p.w
    s.i[k] = w[k] and w[k](v) or v
  end,
}

local __slProxyCachingMt = { 
  __index = function (s, k)
    if k == '__stringify' then return end
    s = s.__data
    local r, v = s.p.r[k], s.i[k]
    if not r then return v end
    local c = s.p.c[k]
    if c then
      local h = c(v)
      if h == s.h[k] then return s.c[k] end
      local n = r(v)
      s.c[k], s.h[k] = n, h
      return n
    end
    return r(v)
  end,
  __newindex = function (s, k, v)
    s = s.__data
    local w = s.p.w
    s.i[k], s.h[k] = w[k] and w[k](v) or v, nil
  end,
}

local __slProxyCache = {}

function ac.StructItem.__proxy(layout, item)
  if type(layout) ~= 'table' then return item end
  local p = __slProxyCache[layout]
  if p == nil then
    for k, v in pairs(layout) do
      local r, w, c = __slProxy(v)
      if r or w then
        if p == nil then p = { r = {}, w = {} } end
        if r then p.r[k] = r end
        if w then p.w[k] = w end
        if c then if not p.c then p.c = {} end p.c[k] = c end
      end
    end
    __slProxyCache[layout] = p or false
  end
  if not p then return item end
  local d = p.c and { l = layout, i = item, p = p, c = {}, h = {} } or { l = layout, i = item, p = p }
  return setmetatable({ __data = d }, p.c and __slProxyCachingMt or __slProxyMt)
end
