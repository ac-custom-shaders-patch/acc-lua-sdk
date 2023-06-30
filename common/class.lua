local function _argsCount(fn)
  if type(fn) == 'function' and (debug and debug.getinfo or _dbg) then
    local i = (debug and debug.getinfo or _dbg)(fn)
    if i ~= nil then
      return i.nparams
    end
  end
  return nil
end

local function _constructorA1(self, a) return setmetatable(self.allocate(a), self) end
local function _constructorA2(self, a, b) return setmetatable(self.allocate(a, b), self) end
local function _constructorA3(self, a, b, c) return setmetatable(self.allocate(a, b, c), self) end
local function _constructorA4(self, a, b, c, d) return setmetatable(self.allocate(a, b, c, d), self) end
local function _constructorAV(self, ...) return setmetatable(self.allocate(...), self) end

local function _constructorIV(self, ...)
  local r = setmetatable(self.allocate(...), self)
  if r.initialize ~= nil then r:initialize(...) end
  return r
end

local function _getConstructor(allocateFn, initializeFn)
  if initializeFn ~= false then return _constructorIV end
  local n = _argsCount(allocateFn)
  if n == 1 then return _constructorA1 end
  if n == 2 then return _constructorA2 end
  if n == 3 then return _constructorA3 end
  if n == 4 then return _constructorA4 end
  return _constructorAV
end

local function _tostringClass(self)
  return 'class '..self.__name
end

local function _tostringGen(self)
  return 'instance of class '..self.__index.__name
end

local function _allocateGen()
  return {}
end

local function _recycleConstructor1(self, a)
  local p = self.__pool
  local n, r = p.n, nil
  if n > 0 then
    p.n, r = n - 1, p[n]
    r.__alreadyRecycled = nil
  else
    r = setmetatable({}, self)
  end
  if r.initialize ~= nil then r:initialize(a) end
  return r
end

local function _recycleConstructor2(self, a, b)
  local p = self.__pool
  local n, r = p.n, nil
  if n > 0 then
    p.n, r = n - 1, p[n]
    r.__alreadyRecycled = nil
  else
    r = setmetatable({}, self)
  end
  if r.initialize ~= nil then r:initialize(a, b) end
  return r
end

local function _recycleConstructor3(self, a, b, c)
  local p = self.__pool
  local n, r = p.n, nil
  if n > 0 then
    p.n, r = n - 1, p[n]
    r.__alreadyRecycled = nil
  else
    r = setmetatable({}, self)
  end
  if r.initialize ~= nil then r:initialize(a, b, c) end
  return r
end

local function _recycleConstructorV(self, ...)
  local p = self.__pool
  local n, r = p.n, nil
  if n > 0 then
    p.n, r = n - 1, p[n]
    r.__alreadyRecycled = nil
  else
    r = setmetatable({}, self)
  end
  if r.initialize ~= nil then r:initialize(...) end
  return r
end

local function _getRecycleConstructor(initializeFn)
  local n = _argsCount(initializeFn)
  if n == 1 then return _recycleConstructor1 end
  if n == 2 then return _recycleConstructor2 end
  if n == 3 then return _recycleConstructor3 end
  return _recycleConstructorV
end

local _classBaseIncluded = nil
local _classPoolIncluded = nil

ClassBase = nil
ClassPool = nil

local function classFactory(self, ...)
  local name = nil
  local parentClass = nil
  local allocateFn = nil
  local initializeFn = nil
  local flags = 0
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    if type(v) == 'string' then
      if name ~= nil then error('Name is already specified', 2) end
      name = v
    elseif type(v) == 'table' then
      if v.new == nil then error('Parent class is required to be a class registered with class() function', 2) end
      if parentClass ~= nil then error('Parent class is already specified', 2) end
      parentClass = v
    elseif type(v) == 'function' then
      if allocateFn == nil then
        allocateFn = v
      elseif initializeFn == nil then
        initializeFn = v
      else
        error('Too many functions provided', 2)
      end
    elseif type(v) == 'number' then
      flags = bit.bor(flags, v)
    elseif v ~= nil then
      error('Unknown argument: '..tostring(v), 2)
    end
  end

  if bit.band(flags, self.Pool) ~= 0 then
    if type(allocateFn) == 'function' then
      if initializeFn ~= nil then
        error('Can’t have allocate function with Pool flag', 2)
      end
      initializeFn = allocateFn
    end
    allocateFn = false
  end

  if bit.band(flags, self.NoInitialize) ~= 0 then
    if initializeFn ~= nil then
      error('Can’t have initialize function with NoInitialize flag', 2)
    end
    initializeFn = false
  end

  local minimalClass = bit.band(flags, self.Minimal) ~= 0
  local classTable
  local classMetatable
  local baseTable = minimalClass and {
    initialize = type(initializeFn) == 'function' and initializeFn or nil,
  } or {
    initialize = type(initializeFn) == 'function' and initializeFn or nil,
    new = function (_, ...) return _ == classTable and classTable(...) or classTable(_, ...) end,
    subclass = function (self, name) return self == classTable and class(self, name) or class(classTable, self) end,
    isSubclassOf = function (self, parent)
      while type(self) == 'table' do
        local mt = getmetatable(self)
        if not mt or mt.__tostring ~= _tostringClass then return false end
        self = mt and mt.__index
        if self == (parent or classTable) then return true end
      end
      return false
    end,
    isInstanceOf = function (self, parent)
      if type(self) ~= 'table' or self.__index == nil then return false end
      if parent == ClassBase then return true end
      if parent == ClassPool then return not not self.__pool end
      return self.__index == (parent or classTable) or self.__index:isSubclassOf(parent or classTable)
    end,
    include = function (self, mixin)
      if self ~= classTable then self, mixin = classTable, self end
      for key, value in pairs(mixin) do
        if key == 'included' then value(self) else self[key] = value end
      end
      return self
    end
  }

  if parentClass ~= nil then
    if parentClass.__pool then
      baseTable.__pool = false
    end

    baseTable.super = parentClass
    baseTable.__tostring = parentClass.__tostring
    baseTable.__call = parentClass.__call
    baseTable.__len = parentClass.__len
  end

  if name ~= nil then
    baseTable.__name = name
    if baseTable.__tostring == nil then
      baseTable.__tostring = _tostringGen
    end
  end

  if allocateFn == false then
    baseTable.__pool = { n = 0 }
    baseTable.recycle = function () end
    constructor = _getRecycleConstructor(initializeFn)
  else
    baseTable.allocate = type(allocateFn) == 'function' and allocateFn or _allocateGen
    constructor = _getConstructor(allocateFn, initializeFn)
  end

  classMetatable = {
    __call = constructor,
    __index = parentClass or (allocateFn == false and _classPoolIncluded or _classBaseIncluded),
    __tostring = _tostringClass
  }

  classTable = setmetatable(baseTable, classMetatable)
  classTable.__index = classTable
  classTable.class = classTable
  if parentClass ~= nil and parentClass.subclassed ~= nil then parentClass:subclassed(classTable) end
  if allocateFn ~= false and parentClass == nil and ClassBase and ClassBase.subclassed ~= nil then ClassBase:subclassed(classTable) end
  if allocateFn == false and parentClass == nil and ClassPool.subclassed ~= nil then ClassPool:subclassed(classTable) end
  return classTable
end

class = setmetatable({
  NoInitialize = 1,
  Pool = 2,
  Minimal = 4,
  recycle = function(item)
    if type(item) ~= 'table' or not item.__pool or item.__alreadyRecycled or item.recycled and item:recycled() == false then return end
    local p = item.__pool
    local n = p.n + 1
    p[n], p.n = item, n
    item.__alreadyRecycled = true
  end,
  emmy = function (classFn, constructorFn)
    return classFn
  end
}, { __call = classFactory })

-- custom semi-virtual classes that can still be used for things like ClassBase.isSubclassOf
ClassBase = class('ClassBase')
function ClassBase:isInstanceOf() return type(self) == 'table' and not not self.__name end
function ClassBase:isSubclassOf() return false end
function ClassBase:subclass(...) return class(...) end

function ClassBase.include(self, mixin)
  if self ~= ClassBase then self, mixin = ClassBase, self end
  if not _classBaseIncluded then
    _classBaseIncluded = {}
  end
  for key, value in pairs(mixin) do
    if key == 'included' then
      value(_classBaseIncluded)
    else
      _classBaseIncluded[key] = value
    end
  end
  return self
end

ClassPool = class('ClassPool', ClassBase)
function ClassPool:recycled() end
function ClassPool:isInstanceOf() return type(self) == 'table' and not not self.__pool end
function ClassPool:isSubclassOf(item) return item == ClassBase end
function ClassPool:subclass(...) return class(class.Pool, ...) end

function ClassPool.include(self, mixin)
  if self ~= ClassPool then self, mixin = ClassPool, self end
  if not _classPoolIncluded then
    if not _classBaseIncluded then _classBaseIncluded = {} end
    _classPoolIncluded = setmetatable({}, { __index = _classBaseIncluded })
  end
  for key, value in pairs(mixin) do
    if key == 'included' then
      value(_classPoolIncluded)
    else
      _classPoolIncluded[key] = value
    end
  end
  return self
end
