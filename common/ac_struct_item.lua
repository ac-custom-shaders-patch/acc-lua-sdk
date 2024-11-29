do

local _li = 1
local _eo = nil
local _fficdef = ffi.cdef

local function counter()
  _li = _li + 1
  return _li
end

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

---Adds a key to a structure to ensure its uniqueness. Consider using something like “yourUsername.yourContentID” or something
---like that for a key, so that your data would not interfere with data from Lua scripts written by other developers. Note:
---if you’re exchanging data between physics and graphics thread in your car, you might have to append `car.index` to there as
---well so that different cars would have either own data things.
---@return nil
function ac.StructItem.key(key) return {key = tostring(key)} end

---Enables explicit ordering for your structures.
---By default, CSP will reorder fields in your structures for optimal data packing. Because all scripts written in Lua share the same algorithm,
---it’s all fine and good, but if you want for your script to exchange data with other programs, explicit order would work much better.
---@param alignment integer? @Optional override for alignment of child structures.
---@param packing integer? @Optional overrider for packing of fields.
---@return nil
function ac.StructItem.explicit(alignment, packing)
  _eo = {tonumber(alignment) or 0, tonumber(packing) or 0}
  return nil
end

---@return number
function ac.StructItem.half() return {t = 0.5, c = counter()} end

---@return number
function ac.StructItem.float() return {t = 1.5, c = counter()} end

---@return number
function ac.StructItem.double() return {t = 2.5, c = counter()} end

---@return number
function ac.StructItem.norm8() return {t = -0.08, c = counter()} end

---@return number
function ac.StructItem.unorm8() return {t = 0.08, c = counter()} end

---@return number
function ac.StructItem.norm16() return {t = -0.16, c = counter()} end

---@return number
function ac.StructItem.unorm16() return {t = 0.16, c = counter()} end

---@return integer
function ac.StructItem.int16() return {t = -16, c = counter()} end

---@return integer
function ac.StructItem.uint16() return {t = 16, c = counter()} end

---@return integer
function ac.StructItem.int32() return {t = -32, c = counter()} end

---@return integer
function ac.StructItem.uint32() return {t = 32, c = counter()} end

---@return integer
function ac.StructItem.int64() return {t = -64, c = counter()} end

---@return integer
function ac.StructItem.uint64() return {t = 64, c = counter()} end

---@return boolean
function ac.StructItem.boolean() return {t = true, c = counter()} end

---Same as `ac.StructItem.int8()`.
---@return integer
function ac.StructItem.char() return {t = -1, c = counter()} end

---Same as `ac.StructItem.uint8()`.
---@return integer
function ac.StructItem.byte() return {t = 1, c = counter()} end

---@return integer
function ac.StructItem.int8() return ac.StructItem.char() end

---@return integer
function ac.StructItem.uint8() return ac.StructItem.byte() end

---@return vec2
function ac.StructItem.vec2() return {t = vec2.tmp(), c = counter()} end

---@return vec3
function ac.StructItem.vec3() return {t = vec3.tmp(), c = counter()} end

---@return vec4
function ac.StructItem.vec4() return {t = vec4.tmp(), c = counter()} end

---@return rgb
function ac.StructItem.rgb() return {t = rgb.tmp(), c = counter()} end

---@return rgbm
function ac.StructItem.rgbm() return {t = rgbm.tmp(), c = counter()} end

---@return hsv
function ac.StructItem.hsv() return {t = hsv.tmp(), c = counter()} end

---@return quat
function ac.StructItem.quat() return {t = quat.tmp(), c = counter()} end

---@generic T
---@param elementType T
---@param size integer
---@return T[]
function ac.StructItem.array(elementType, size)
  if type(elementType) == 'string' then error('Can’t have an array of strings', 2) end
  -- if type(elementType) == 'table' then error('Can’t have an array of arrays or special types', 2) end
  return {t = {array = size, type = elementType}, c = counter()}
end

---@generic T
---@param fields T
---@return T
function ac.StructItem.struct(fields)
  if next(fields) == nil then error('Empty sub-structs are not allowed', 2) end
  if table.isArray(fields) then error('Use `ac.StructItem.array()` for arrays', 2) end
  return {t = {struct = fields}, c = counter()}
end

---@param capacity integer? @Maximum string capacity. Default value: 32.
---@return string
function ac.StructItem.string(capacity) return {t = tostring(capacity or 32), c = counter()} end

---@return mat3x3
function ac.StructItem.mat3x3() return {t = {'mat3x3 %s;', 36, false, false, false, 901}, c = counter()} end

---@return mat4x4
function ac.StructItem.mat4x4() return {t = {'mat4x4 %s;', 64, false, false, false, 1601}, c = counter()} end

---Matrix packed to 6, 9 or 12 bytes (depending on settings).
---
---Note: to update value you need to use assignment operator (`.field = newValue`), altering matrix of this property with methods like
---`:mulSelf()` only changes unpacked value on your side, but not the actual structure value.
---@param compactPosition boolean? @If `true`, position is packed into 3 bytes, otherwise it will take 6 bytes. Default value: `false`.
---@param compactRotation boolean? @If `true`, rotation is packed into 3 bytes, otherwise it will take 6 bytes. Default value: `false`.
---@param rangeFrom number|vec3? @Minimal expected position. Pass it together with `rangeTo` to encode position data more efficiently.
---@param rangeTo number|vec3? @Maximum expected position. Pass it together with `rangeFrom` to encode position data more efficiently.
---@return mat4x4
function ac.StructItem.transform(compactPosition, compactRotation, rangeFrom, rangeTo) 
  compactPosition = compactPosition == true
  compactRotation = compactRotation == true
  if not rangeFrom then rangeFrom = nil elseif not vec3.isvec3(rangeFrom) then rangeFrom = vec3.new(rangeFrom) end
  if not rangeTo then rangeTo = nil elseif not vec3.isvec3(rangeTo) then rangeTo = vec3.new(rangeTo) end
  local size = (compactPosition and 3 or 6) + (compactRotation and 3 or 6)
  return { 
    t = {
      string.format('char %%s[%d];', size),
      size,
      function()
        local t = mat4x4()
        return function(v) ffi.C.lj_mat_unpack(v, t, compactPosition, rangeFrom, rangeTo, compactRotation) return t end
      end,
      function ()
        return function(v, dst) ffi.C.lj_mat_pack(dst, v, compactPosition, rangeFrom, rangeTo, compactRotation) end
      end,
      function()
        return function(v) return __util.ffistrhash(v, size) end
      end 
    },
    c = counter()
  }
end

local __slTypes = {
  [-0.08] = { 'int8_t %s;', 1, function (v) return v / 127 end, function (v) return math.max(math.min(v, 1), -1) * 127 end, false, 3 },
  [0.08] = { 'uint8_t %s;', 1, function (v) return v / 255 end, function (v) return math.max(math.min(v, 1), 0) * 255 end, false, 4 },
  [-0.16] = { 'int16_t %s;', 2, function (v) return v / 32767 end, function (v) return math.max(math.min(v, 1), -1) * 32767 end, false, 5 },
  [0.16] = { 'uint16_t %s;', 2, function (v) return v / 65535 end, function (v) return math.max(math.min(v, 1), 0) * 65535 end, false, 6 },
  [0.5] = { 'uint16_t %s;', 2, function (v) return ac.decodeHalf(v) end, function (v) return ac.encodeHalf(v) end, false, 2 },
  [1.5] = { 'float %s;', 4, false, false, false, 1 },
  [2.5] = { 'double %s;', 8, false, false, false, 0 },
  [-1] = { 'char %s;', 1 },
  [1] = { 'uint8_t %s;', 1 },
  [-8] = { 'int8_t %s;', 1 },
  [8] = { 'uint8_t %s;', 1 },
  [-16] = { 'int16_t %s;', 2 },
  [16] = { 'uint16_t %s;', 2 },
  [-32] = { 'int %s;', 4 },
  [32] = { 'uint32_t %s;', 4 },
  [-64] = { 'int64_t %s;', 8 },
  [64] = { 'uint64_t %s;', 8 },
  [true] = { 'bool %s;', 1 },
  [vec2.tmp()] = { 'vec2 %s;', 8, false, false, false, 201 },
  [vec3.tmp()] = { 'vec3 %s;', 12, false, false, false, 301 },
  [vec4.tmp()] = { 'vec4 %s;', 16, false, false, false, 401 },
  [rgb.tmp()] = { 'rgb %s;', 12, false, false, false, 301 },
  [rgbm.tmp()] = { 'rgbm %s;', 16, false, false, false, 401 },
  [hsv.tmp()] = { 'hsv %s;', 12, false, false, false, 301 },
  [quat.tmp()] = { 'quat %s;', 16, false, false, false, 401 },
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
  },
}

local function __slGet(value, col)
  local t = __slTypes[value]
  if t then return t[col] end
  if type(value) == 'table' then t = value else t = __slTypes[type(value)] end
  local c = t and t[col]
  if type(c) == 'function' then return c(value) end
  return c
end

local function __slBuild(types, callback)
  local ordered = types
  table.sort(ordered, _eo and function (a, b)
    return a.createdIndex < b.createdIndex
  end or function (a, b)
    if a.packingSize ~= b.packingSize then return a.packingSize > b.packingSize end
    return a.name < b.name
  end)
  local reordered, i, c, pos = {}, 1, #ordered, 0
  if _eo then
    reordered = ordered
  else
    while i <= c do
      if ordered[i] ~= nil then
        local v, l = ordered[i], 8 - pos % 8
        if v.realSize > 1 and v.realSize <= 8 and l < v.realSize then
          for j = i + 1, c do
            if ordered[j] ~= nil and ordered[j].realSize > 0 and ordered[j].realSize <= l then
              v, i, ordered[j] = ordered[j], i - 1, nil
              break
            end
          end
        end
        table.insert(reordered, v)
        pos = pos + v.realSize
      end
      i = i + 1
    end
  end
  if callback then
    callback(reordered)
  end
  local prepared = table.map(reordered, function(item)
    if item.array then 
      return string.format(item.type, item.name..'['..table.concat(item.array, '][')..']')
    end
    return string.format(item.type, item.name)
  end)
  return prepared, reordered
end

local function __slMapOrdered(items, callback, data)
  local ret = {}
  if _eo then
    for k, v in pairs(items) do
      local j = callback(v, k, data)
      if j then
        table.insert(ret, j)
      end
    end
  else
    local ordered, n = {}, 1
    for k, v in pairs(items) do
      ordered[n], n = {k, v}, n + 1
    end
    table.sort(ordered, function (a, b)
      return tostring(a[1]) < tostring(b[1])
    end)
    for i = 1, n - 1 do
      local j = callback(ordered[i][2], ordered[i][1], data)
      if j then
        table.insert(ret, j)
      end
    end
  end
  return ret
end

local function __slTypeInfo(item, index, namespace)
  if type(item) ~= 'table' then
    error('Invalid struct item', 2)
  end
  if item.key then
    namespace.key = item.key
    return nil
  end
  if type(item.t) == 'table' then
    if item.t.array then
      local ret = __slTypeInfo(item.t.type, index, namespace)
      if ret then
        if not ret.array then ret.array = {} end
        table.insert(ret.array, 1, item.t.array)
        ret.realSize = ret.realSize * item.t.array
        ret.createdIndex = item.c
      end
      return ret
    end
    if item.t.struct then
      local totalSize = 0
      local fields = __slMapOrdered(item.t.struct, function (sub, key)
        local r = __slTypeInfo(sub, key, namespace)
        if r then totalSize = totalSize + r.realSize end
        return r
      end)
      local built, reordered = __slBuild(fields)
      local prepared = table.concat(built)
      local existing = table.indexOf(namespace.structs, prepared)
      if not existing then
        existing = #namespace.structs + 1
        namespace.structs[existing] = prepared
      end
      return {
        name = index,
        type = '__<STRUCTNAME>_'..existing..' %s;',
        packingSize = totalSize,
        realSize = totalSize,
        struct = reordered,
        createdIndex = item.c
      }
    end
  end

  local s = __slGet(item.t, 2) or error('Unknown type: '..item.t, 2)
  return {
    name = index,
    type = __slGet(item.t, 1) or error('Unknown type: '..item.t, 2),
    replayType = __slGet(item.t, 6),
    packingSize = s,
    realSize = s,
    createdIndex = item.c
  }
end

local function __slProxy(value)
  return __slGet(value.t, 3) or false, __slGet(value.t, 4) or false, __slGet(value.t, 5) or false
end

function __util.__si_build(items, callback)
  if type(items) == 'string' then
    return items
  end
  if type(items) ~= 'table' or table.isArray(items) then
    error('Associative table is required', 2)
  end
  local namespace = {key = nil, structs = {}}
  local prepared, reordered = __slBuild(__slMapOrdered(items, __slTypeInfo, namespace), callback)
  if namespace.key then table.insert(prepared, '//'..tostring(namespace.key)) end
  if #namespace.structs > 0 then
    table.insert(prepared, '\n__<STRUCTINNER>_')
    for i = 1, #namespace.structs do
      local a = _eo == nil and 1 or _eo[1]
      table.insert(prepared, a > 0
        and string.format('typedef struct __declspec(align(%d)){%s}__<STRUCTNAME>_%d;', a, namespace.structs[i], i)
        or string.format('typedef struct{%s}__<STRUCTNAME>_%d;', namespace.structs[i], i))
    end
  end
  if _eo then
    table.insert(prepared, string.format('//<__EXPAL:%s:%s>', _eo[1] or 0, _eo[2] or 0))
    _eo = nil
  end
  return table.concat(prepared), reordered
end

local _known = {}

function __util.__si_cdef(name, layout, compact)
  local f = string.find(layout, '\n__<STRUCTINNER>_', 1, true)
  local e = string.find(layout, '//<__EXPAL:', f or 1, true)
  local align, pack = -1, -1
  if e then
    local e1 = string.find(layout, ':', e + 12, true)
    local e2 = string.find(layout, '>', e1 + 2, true)
    align, pack = tonumber(string.sub(layout, e + 11, e1 - 1)), tonumber(string.sub(layout, e1 + 1, e2 - 1))
  elseif compact then
    align, pack = 1, 1
  end
  local u
  if f then
    -- There are inner structures, and if explicit packing is not set they have to have their own 1-byte packing
    u = string.replace(string.sub(layout, f + 17), '<STRUCTNAME>', name)
    layout = string.replace(string.sub(layout, 1, f), '<STRUCTNAME>', name)
  end
  local r, n = {}, 1
  if pack > 0 or u and not e then
    r[n], n = '#pragma pack(push, ', n + 1
    r[n], n = tostring(math.max(pack, 1)), n + 1
    r[n], n = ')\n', n + 1
  end
  if u then
    r[n], n = u, n + 1
    r[n], n = pack > 0 and '\n' or '\n#pragma pack(pop)\n', n + 1
  end
  r[n], n = 'typedef struct ', n + 1
  if align > 0 then 
    r[n], n = '__declspec(align(', n + 1
    r[n], n = tostring(align), n + 1
    r[n], n = ')){\n', n + 1
  else
    r[n], n = '{\n', n + 1
  end
  r[n], n = layout, n + 1
  r[n], n = '\n} ', n + 1
  r[n], n = name, n + 1
  r[n], n = ';', n + 1
  if pack > 0 then
    r[n], n = '\n#pragma pack(pop)', n + 1
  end
  return table.concat(r)
end

-- -@param layoutStr string
-- -@param compact boolean?
-- -@return string
-- -@return string

function __util.__si_ffi(layoutStr, compact)
  if type(layoutStr) == 'table' then layoutStr = __util.__si_build(layoutStr) end
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 3) end
  local k = _known[layoutStr]
  if not k then
    k = '__sif_'..math.randomKey()
    _fficdef(__util.__si_cdef(k, layoutStr, compact))
    _known[layoutStr] = k
  end
  return k, layoutStr
end

local __slProxyMt = { 
  __index = function (s, k)
    if k == '__stringify' or k == '__blobify' then return end
    s = s.__data_cdata__
    local r, v = s.p.r[k], s.i[k]
    if not r then return v end
    return r(v)
  end,
  __newindex = function (s, k, v)
    s = s.__data_cdata__
    local w = s.p.w
    if w[k] then
      local i = w[k](v, s.i[k])
      if i ~= nil then s.i[k] = i end
    else
      s.i[k] = v
    end
  end,
}

local __slProxyCachingMt = { 
  __index = function (s, k)
    if k == '__stringify' or k == '__blobify' then return end
    s = s.__data_cdata__
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
    s = s.__data_cdata__
    local w = s.p.w
    if w[k] then
      local i = w[k](v, s.i[k])
      if i ~= nil then s.i[k] = i end
    else
      s.i[k] = v
    end
    s.h[k] = nil
  end,
}

local __slProxyCache = {}

function __util.__si_proxy(layout, item)
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
  return setmetatable({ __data_cdata__ = d }, p.c and __slProxyCachingMt or __slProxyMt)
end

end
