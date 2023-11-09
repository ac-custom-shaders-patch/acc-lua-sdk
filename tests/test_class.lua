require('common/class')

local classesBase = {}
local classesChildren = {}
local classesPool = {}
function ClassBase:subclassed(classDef)
  table.insert(classesBase, classDef)
  classDef.subclassed = function (classDef, newClassDef)
    table.insert(classesChildren, newClassDef)
    newClassDef.subclassed = classDef.subclassed
  end
end
function ClassPool:subclassed(classDef)
  table.insert(classesPool, classDef)
end

local ClassSimple = class('ClassBasic')
function ClassSimple:initialize() self.a = 1 end
local cbi = ClassSimple()
expect(cbi.a, 1)
expect(ClassSimple.isInstanceOf(cbi), true)
expect(cbi:isInstanceOf(ClassSimple), true)
expect(ClassBase.isInstanceOf(cbi), true)
expect(cbi:isInstanceOf(ClassBase), true)
expect(ClassSimple.isInstanceOf({}), false)
expect(ClassBase.isInstanceOf({}), false)
expect(ClassSimple.isInstanceOf(nil), false)
expect(ClassBase.isInstanceOf(nil), false)

local ClassChild = class('ClassChild', ClassSimple)
local cci = ClassChild()
expect(ClassSimple.isInstanceOf(cci), true)
expect(cci:isInstanceOf(ClassSimple), true)
expect(ClassChild.isInstanceOf(cci), true)
expect(cci:isInstanceOf(ClassChild), true)
expect(ClassBase.isInstanceOf(cci), true)
expect(cci:isInstanceOf(ClassBase), true)

expect(ClassChild:isInstanceOf(ClassSimple), true)
expect(ClassChild:isInstanceOf(ClassChild), true)
expect(ClassSimple.isInstanceOf(ClassChild), true)
expect(ClassSimple:isInstanceOf(ClassChild), false)
expect(ClassChild.isInstanceOf(ClassSimple), false)
expect(ClassChild:isSubclassOf(ClassSimple), true)
expect(ClassChild:isSubclassOf(ClassChild), false)
expect(ClassSimple.isSubclassOf(ClassChild), true)
expect(ClassSimple:isSubclassOf(ClassChild), false)
expect(ClassChild.isSubclassOf(ClassSimple), false)
expect(cci:isSubclassOf(ClassSimple), false)
expect(cci:isSubclassOf(ClassChild), false)
expect(ClassChild:isSubclassOf(cbi), false)

local n = (function ()
  local ClassSimple = ClassBase:subclass('ClassBasic', ClassBase)
  function ClassSimple:initialize() self.a = 1 end
  local cbi = ClassSimple()
  expect(cbi.a, 1)
  expect(tostring(ClassSimple), 'class ClassBasic')
  expect(tostring(cbi), 'instance of class ClassBasic')
  expect(ClassSimple.isInstanceOf(cbi), true)
  expect(cbi:isInstanceOf(ClassSimple), true)
  expect(ClassBase.isInstanceOf(cbi), true)
  expect(cbi:isInstanceOf(ClassBase), true)
  expect(ClassSimple.isInstanceOf({}), false)
  expect(ClassBase.isInstanceOf({}), false)
  expect(ClassSimple.isInstanceOf(nil), false)
  expect(ClassBase.isInstanceOf(nil), false)
  
  local ClassChild = class('ClassChild', ClassSimple)
  local cci = ClassChild()
  expect(ClassSimple.isInstanceOf(cci), true)
  expect(cci:isInstanceOf(ClassSimple), true)
  expect(ClassChild.isInstanceOf(cci), true)
  expect(cci:isInstanceOf(ClassChild), true)
  expect(ClassBase.isInstanceOf(cci), true)
  expect(cci:isInstanceOf(ClassBase), true)
  
  expect(ClassChild:isInstanceOf(ClassSimple), true)
  expect(ClassChild:isInstanceOf(ClassChild), true)
  expect(ClassSimple.isInstanceOf(ClassChild), true)
  expect(ClassSimple:isInstanceOf(ClassChild), false)
  expect(ClassChild.isInstanceOf(ClassSimple), false)
  expect(ClassChild:isSubclassOf(ClassSimple), true)
  expect(ClassChild:isSubclassOf(ClassChild), false)
  expect(ClassSimple.isSubclassOf(ClassChild), true)
  expect(ClassSimple:isSubclassOf(ClassChild), false)
  expect(ClassChild.isSubclassOf(ClassSimple), false)
  expect(cci:isSubclassOf(ClassSimple), false)
  expect(cci:isSubclassOf(ClassChild), false)
  expect(ClassChild:isSubclassOf(cbi), false)
end)()

-- expect(ClassBase.isSubclassOf(ClassSimple()), true)
-- expect(ClassBase.isSubclassOf({}), false)

local classBasic = class('classBasic', ClassBase)
function classBasic:initialize() self.a = 1 end
expect(classBasic().a, 1)
expect(ClassBase.isInstanceOf(classBasic()), true)
-- expect(ClassBase.isSubclassOf(classBasic()), true)

local classAllocate = class('classAllocate')
function classAllocate.allocate() return { a = 2} end
expect(classAllocate().a, 2)

-- expectError(function () classAllocate:subclass() end, 'Can’t make a child class of a customly allocating class')
-- expectError(function () class(classAllocate) end, 'Can’t make a child class of a customly allocating class')
-- expectError(function () local c = class(classAllocate) c() end, 'classAllocate:initialize()')

local classInlineAllocate = class(nil, function () return { a = 3 } end)
expect(classInlineAllocate().a, 3)

local classInlineAll = class(function () return {} end, function (self) self.a = 4 end)
expect(classInlineAll().a, 4)

expectError(function ()
  class(function () return {} end, function (self) self.a = 4 end, class.NoInitialize)
end, 'initialize function with NoInitialize flag')

local classPool = class(class.Pool)
function classPool:initialize(v) self.v = v end
function classPool:get(a) return self.v + a end
local i1 = classPool(5)
expect(i1:get(10), 15)
local i2 = classPool(6)
expect(i2:get(10), 16)
class.recycle(i1)
local i3 = classPool(7)
expect(i3:get(10), 17)

expect(classPool.__pool.n, 0)
expect(i2 == i3, false)

class.recycle(i2)
class.recycle(i3)

expect(classPool.__pool.n, 2)
expect(classPool.__pool[1] == classPool.__pool[2], false)

local i4 = classPool(8)
local i5 = classPool(9)
local i6 = classPool(10)
expect(i4.v, 8)
expect(i5.v, 9)
expect(i6.v, 10)
expect(i4 == i5, false)

expect((function ()
  local classPool = class(class.Pool)
  local i = 0
  function classPool:recycled()
    i = i + 1
  end
  local i0 = classPool()
  class.recycle(i0)
  class.recycle(i0)
  return i
end)(), 1)

local classNewPool = class(class.Pool)
function classNewPool:recycled()
  return false
end
local i = classNewPool()
class.recycle(i)
expect(classNewPool.__pool.n, 0)

expect(ClassPool.isInstanceOf(i), true)
expect(ClassPool.isInstanceOf(cbi), false)
expect(ClassPool.isSubclassOf(i), false)
expect(i:isInstanceOf(ClassPool), true)
expect(cbi:isInstanceOf(ClassPool), false)
expect(ClassPool:isSubclassOf(ClassBase), true)
expect(ClassBase:isSubclassOf(ClassPool), false)

local classCall = class()
function classCall:__call()
  return 123
end
local cc = classCall()
expect(cc(), 123)

expect((function ()
  local classPool = ClassPool:subclass()
  local i = 0
  function classPool:recycled()
    i = i + 1
  end
  local i0 = classPool()
  class.recycle(i0)
  class.recycle(i0)
  return i
end)(), 1)


local ClassM = class('ClassM')
function ClassM:initialize(v) self.key = 20 + (v or 0) end
ClassM.value = 10

ClassM:include({ 
  someKey = 'someValue',
  foo = function(self) return self.key end,
  included = function (c)
    expect(c.value, 10)
    c.randomKey = 30
  end 
})
local m = ClassM()
expect(m.someKey, 'someValue')
expect(m.randomKey, 30)
expect(m:foo(), 20)


-- middleclass style of calling parent constructor
local ClassMCD = ClassM:subclass('ClassMC')
function ClassMCD:initialize()
  ClassM.initialize(self, 1)
  expect(ClassM.foo(self), 21)
  expect(self:foo(), 22)
end
function ClassMCD:foo()
  return 22
end
local mc = ClassMCD()
expect(mc.key, 21)


-- print('TESTING CLASS_MC')
local ClassMC = ClassM:subclass('ClassMC')
function ClassMC:initialize()
  ClassM.initialize(self, 1)
  self.q = '5'
  -- print('  CLASS_MC: '..tostring(self:foo()))
  expect(self.key, 21)
  expect(ClassM.foo(self), 21)
  if getmetatable(self) == ClassMC then 
    expect(self.super.foo(self), 21) -- not as neat, but that should work
    expect(self.foo, ClassMC.foo)
    expect(self:foo(), 22) 
  end
end
function ClassMC:foo()
  return 22
end
expect(tostring(ClassMC), 'class ClassMC')
local mc = ClassMC()
expect(tostring(mc), 'instance of class ClassMC')
expect(mc.key, 21)
expect(getmetatable(mc), ClassMC)
expect(mc.foo, ClassMC.foo)

-- print('TESTING CLASS_MCC')
local ClassMCC = class('ClassMCC', ClassMC)
function ClassMCC:initialize(a1)
  self.a1 = a1
  -- print('  CLASS_MCC: '..tostring(a1))
  -- print('  self.super: '..tostring(self.super.initialize))
  ClassMC.initialize(self)
  expect(self.super.super.foo(self), 21)
  expect(self.super.foo(self), 22)
  expect(self:foo(), 123)
end
function ClassMCC:foo()
  return 123
end
local mcc = ClassMCC()
expect(mcc.key, 21)
expect(mcc.q, '5')
expect(getmetatable(mcc), ClassMCC)
expect(mcc.foo, ClassMCC.foo)


local c0 = class('C0')
function c0:initialize(a)
  self.a = a
end

local c1 = class('C1', c0)
function c1:initialize(a, b)
  c0.initialize(self, a)
  self.b = b
end

local ci = c1('A', 'B')
expect(ci.a, 'A')
expect(ci.b, 'B')

expect(c1.super, c0)


ClassBase:include({ ohhowfun = function () return 'yes!' end })
ClassBase:include({ orisit = function (self, arg) return 'so yes: '..tostring(self) end, included = function (t) expect(t.ohhowfun(), 'yes!') end })
ClassPool:include({ poolM = function (self, arg) return 171 + arg end, included = function (t) expect(t.ohhowfun(), 'yes!') end })

local classFun = class('classFun')
local c = classFun()
expect(c:ohhowfun(), 'yes!')
expect(c:orisit('test'), 'so yes: instance of class classFun')
expect(c.poolM, nil)

local cf2 = class('cf2', class.Pool)
local c2 = cf2()
expect(c2:ohhowfun(), 'yes!')
expect(c2:orisit('test'), 'so yes: instance of class cf2')
expect(c2:poolM(100), 271)

-- ClassBase:include()

expect(#classesBase, 10)
expect(classesBase[1].__name, 'ClassBasic')

expect(#classesChildren, 6)
expect(classesChildren[1].__name, 'ClassChild')
expect(classesChildren[#classesChildren].__name, 'C1')
expect(classesChildren[#classesChildren - 1].__name, 'ClassMCC')

expect(#classesPool, 5)
expect(classesPool[#classesPool].__name, 'cf2')

-- seems like bitser thinks we are hump.class, great
local bitser = require('tests/data/bitser')
local BitserClass = class('BitserClass')
function BitserClass:initialize(arg1) 
  self.value = arg1
end
function BitserClass:add(arg2) 
  return self.value + arg2
end

expect(BitserClass.__index, BitserClass)
bitser.registerClass(BitserClass)
local serializedString = bitser.dumps({ key = 'value', ins = BitserClass(17) })
local someValue = bitser.loads(serializedString)
expect(someValue.key, 'value')
expect(someValue.ins.value, 17)
expect(BitserClass.isInstanceOf(someValue.ins), true)  -- how neat is that!




local PureID_ElementConnect = class('PureID_ElementConnect')

function PureID_ElementConnect:initialize(section)
  self.section = section
end

local PureUI_Slider = class('PureUI_Slider', PureID_ElementConnect)

function PureUI_Slider:initialize(section)
  PureID_ElementConnect.initialize(self, section)
end

local slider = PureUI_Slider('test')
expect(slider.section, 'test')



local cT1 = class('cT1')
function cT1:test()
  self.key = (self.key or 1) + 1 
  return self.key
end

local t1 = cT1()
expect(t1:test(), 2)
expect(t1:test(), 3)
t1.test = function (self)
  self.key = (self.key or 1) + 10
  return self.key
end
expect(t1:test(), 13)
t1.test = nil
expect(t1:test(), 14)