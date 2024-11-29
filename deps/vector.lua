-- Copyright (c) 2012-2014 Evan Wies.  All rights reserved.
-- MIT License, see the COPYRIGHT file.
-- https://github.com/neomantra/lds

ffi.cdef [[
void* lj_calloc(size_t count, size_t size);
void* lj_realloc(void *ptr, size_t size);
void* lj_memmove(void* base, void *dst, const void *src, size_t len);
void lj_free(void *ptr); 
]]

local MallocAllocatorT__mt = {
  __index = {
    allocate  = function(self, n)
      return ffi.C.lj_calloc( n, self._ct_size )
    end,
    deallocate = function(self, p)
      if p ~= 0 then ffi.C.lj_free(p) end
    end,
    reallocate = function(self, p, n)
      return ffi.C.lj_realloc(p, n)
    end,
  }
}

local function MallocAllocatorT( ct, which )
  if type(ct) ~= 'cdata' then error('argument 1 is not a valid "cdata"', 2) end
  local t_mt = table.clone(MallocAllocatorT__mt, true)
  t_mt.__index._ct = ct
  t_mt.__index._ct_size = ffi.sizeof(ct)
  local t_anonymous = ffi.typeof('struct {}')
  return ffi.metatype(t_anonymous, t_mt)
end

local function MallocAllocator(ct)
  return MallocAllocatorT(ct)()
end

local function VectorT__resize(v, reserve_n, shrinkToFit)
  if not reserve_n then reserve_n = 2 * v._cap end
  local new_cap = math.max(1, reserve_n, shrinkToFit and 1 or 2 * v._cap)
  if v._cap >= new_cap then return end
  local new_data = v.__alloc:reallocate(v.raw, new_cap * v.__ctSize)
  v.raw = ffi.cast(v.raw, new_data)
  v._cap = new_cap
end 

local Vector = {}

function Vector:size()
  return self._size
end

function Vector:sizeBytes()
  return self._size * self.__ctSize
end

function Vector:isEmpty()
  return self._size == 0
end

function Vector:capacity()
  return self._cap
end

function Vector:capacityBytes()
  return self._cap * self.__ctSize
end

function Vector:reserve(reserve_n)
  VectorT__resize(self, reserve_n)
end

function Vector:resize(newSize)
  VectorT__resize(self, newSize)
  self._size = newSize
end

function Vector:shrinkToFit()
  VectorT__resize(self, self._size, true)
end

function Vector:get(i)
  if i < 1 or i > self._size then return nil end
  return self.raw[i - 1]
end

function Vector:data()
  return self.raw
end

function Vector:set(i, x)
  if x == nil then self:remove(i) end
  if i > self._size + 1 then i = self._size + 1 end
  if i > self._cap then
    VectorT__resize(self, math.max(i, self._cap * 2))
    self._size = i
  elseif i < 1 then return nil end
  self.raw[i - 1] = x
  if i > self._size then self._size = i end
  if self.__keepAlive then
    self.__keepAlive[i] = x
  end
end

function Vector:insert(i, x)
  if type(x) == 'nil' then self:push(i) 
  elseif i < 1 then error('insert: index out of bounds', 2)
  elseif i > self._size then self:push(x) 
  else
    if self._size + 1 > self._cap then VectorT__resize(self) end
    ffi.C.lj_memmove(self.raw, self.raw + i, self.raw + i - 1, (self._size - i + 1) * self.__ctSize)
    self.raw[i - 1] = x
    self._size = self._size + 1
    if self.__keepAlive then
      table.insert(self.__keepAlive, i, x)
    end
  end
end

function Vector:push(x)
  if x == nil then return end
  self:set(self._size + 1, x)
end

function Vector:pushWhereFits(x)
  for i = 1, #self do
    if self:get(i) == nil then
      self:set(i, x)
      return i
    end
  end
  self:push(x)
  return #self
end

function Vector:erase(x)
  for i = 1, #self do
    if self:get(i) == x then
      self:remove(i)
      return
    end
  end
end

function Vector:remove(i)
  if type(i) == 'nil' then return self:pop() end
  if i < 1 or i > self._size then return nil end
  local x = self.raw[i - 1]
  ffi.C.lj_memmove(self.raw, self.raw + i - 1, self.raw + i, (self._size - i + 1) * self.__ctSize)
  self._size = self._size - 1
  if self.__keepAlive then
    table.remove(self.__keepAlive, i)
  end
  return x
end

function Vector:pop()
  if self._size == 0 then return nil end
  local x = self.raw[self._size - 1]
  self._size = self._size - 1
  if self.__keepAlive then
    table.remove(self.__keepAlive, #self.__keepAlive)
  end
  return x
end

function Vector:__blobify()
  return self.raw, self._size * self.__ctSize
end

function Vector:clear()
  self._size = 0
  if self.__keepAlive then
    table.clear(self.__keepAlive)
  end
end

function Vector:clone()
  if self.__cb then
    error('Can’t clone bound arrays', 2)
  end
  if self.__keepAlive then
    error('Can’t clone arrays with non-primitive data', 2)
  end
  local r = __util.arrayType(self.__ct)()
  r:resize(self._size)
  for i = 0, self._size - 1 do
    r.raw[i] = self.raw[i]
  end
  return r
end

local VectorT__mt = {
  __new = function(vt, reserve, data)
    local self = ffi.new(vt)
    if data then
      if type(data) == 'table' then
        local len, j = #data, 0
        self.raw = self.__alloc:allocate(len)
        for i = next(data) or 1, len do
          self.raw[j], j = data[i], j + 1
        end
        self._size, self._cap = j, len
      elseif type(data) == 'number' then
        if reserve < data then reserve = data end
        self.raw, self._size, self._cap = self.__alloc:allocate(reserve), data, reserve
      elseif type(data) == 'cdata' then
        self.raw, self._size, self._cap = data, reserve, reserve
      else
        error('Unsupported initialization data', 2)
      end
    elseif reserve and reserve > 0 then
      self.raw, self._size, self._cap = self.__alloc:allocate(reserve), 0, reserve
    else
      self.raw, self._size, self._cap = nil, 0, 0
    end
    if self.__cb then self.__cb(self) end
    return self
  end,
  __gc = function(self)
    self.__alloc:deallocate(self.raw)
    if self.__keepAlive then self.__keepAlive = {} end
    self.raw, self._cap, self._size = nil, 0, 0
    if self.__cb then self.__cb(nil) end
    return self
  end,
  __len = function( self ) return self._size end,
  __index = Vector,
  __newindex = function (self, k, v) return self:set(k, v) end,
}

local function VectorT(ct, cb, keepAlive)
  if type(ct) ~= 'cdata' then error('argument 1 is not a valid “cdata”', 2) end

  local vtmt = table.clone(VectorT__mt, true)
  vtmt.__index.__ct = ct
  vtmt.__index.__ctSize = ffi.sizeof(ct)
  vtmt.__index.__alloc = MallocAllocator(ct)
  vtmt.__index.__keepAlive = keepAlive and {} or false
  vtmt.__index.__cb = cb or false

  local vt = ffi.typeof([[ struct { $ * raw; int _size; int _cap; } ]], ct)
  if keepAlive then
    local result = ffi.metatype(vt, vtmt)
    setmetatable(vtmt.__index, { __index = function (self, k) return result:get(k) end })
    return result
  else
    return ffi.metatype(vt, vtmt)
  end
end

function __util.boundArray(ct, cb)
  return VectorT(ct, cb, true)(16)
end

local __arrayTypeCache = {}
function __util.arrayType(ct)
  local cache = __arrayTypeCache[ct]
  if cache then return cache end
  local created = VectorT(ct, nil, false)
  __arrayTypeCache[ct] = created
  return created
end

function __util.stealVector(s, steal)
  if not steal then return s.raw, s._size, -1 end
  local r0, r1, r2 = s.raw, s._size, s._cap
  s.raw, s._size, s._cap = nil, 0, 0
  return r0, r1, r2
end
