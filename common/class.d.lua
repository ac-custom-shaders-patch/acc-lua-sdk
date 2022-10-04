---@meta
---@alias ClassDefinition {__name: string}
---@alias ClassMixin {included: fun(classDefinition: ClassDefinition)}

---A base class. Note: all classes are inheriting from this one even if they’re not using
---`ClassBase` as a parent class explicitly.
ClassBase = {}

---Checks if object is an instance of a class created by `class()` function.
---@param obj any|nil @Any table, vector, nil, anything.
---@return boolean @True if type of `obj` is `ClassBase` or any class inheriting from it.
function ClassBase.isInstanceOf(obj) end

---Checks if ClassBase is a subsclass of a class created by `class()` function. It wouldn’t be, function is here just for
---keeping things even.
---@param classDefinition ClassDefinition @Class created by `class()` function.
---@return boolean @Always false.
function ClassBase:isSubclassOf(classDefinition) end

---Creates a new class. Pretty much the same as calling `class()` (all classes are inheriting from `ClassBase` anyway).
---@return ClassDefinition @New class definition
function ClassBase:subclass(...) end

---Adds a mixin to all subsequently created classes. Use it early in case you want to add a method or some data to all of your objects.
---If `mixin` has a property `included`, it would be called each time new class is created with a reference to the newly created class.
---@param mixin ClassMixin
function ClassBase:include(mixin) end

---Define this function and it would be called each time a new class without a parent (or `ClassBase` for parent) is created.
---@param classDefinition ClassDefinition
function ClassBase:subclassed(classDefinition) end

---A base class for objects with pooling. Note: all classes created with `class.Pool` flag are inheriting from this one even if they’re not using
---`ClassPool` as a parent class explicitly.
ClassPool = {}

---Checks if object is an instance of a class with pooling active.
---@param obj any|nil @Any table, vector, nil, anything.
---@return boolean @True if type of `obj` is `ClassPool` or any class inheriting from it.
function ClassPool.isInstanceOf(obj) end

---Checks if ClassPool is a subsclass of a class created by `class()` function. It wouldn’t be unless you’re passing `ClassBase`, function is here just for
---keeping things even.
---@param classDefinition ClassBase @Class created by `class()` function.
---@return boolean @True if you’ve passed ClassBase here.
function ClassPool:isSubclassOf(classDefinition) end

---Creates a new class with pooling. Pretty much the same as calling `class(class.Pool, ...)` (all classes with `class.Pool` are 
---inheriting from `ClassPool` anyway).
---@return ClassDefinition @New class definition
function ClassPool:subclass(...) end

---Adds a mixin to subsequently created classes with pooling. Use it early in case you want to add a method or some data to all of your objects that use pooling.
---If `mixin` has a property `included`, it would be called each time new class with pooling is created with a reference to the newly created class.
---@param mixin ClassMixin
function ClassPool:include(mixin) end

---Define this function and it would be called each time a new pooling class without a parent (or `ClassPool` for parent) is created.
---@param classDefinition ClassDefinition
function ClassPool:subclassed(classDefinition) end

---A base class. Note: all classes are inheriting from this one even if they’re not using
---`ClassBase` as a parent class explicitly. You might still want to put it in EmmyDoc comment to get hints for functions like `YourClass.isInstanceOf()`.
---@class ClassBase
local _classBase = {}

---Checks if object is an instance of this class. Can be used either as `obj:isInstanceOf(YourClass)` or, as a safer alternative,
---`YourClass.isInstanceOf(obj)` — this one would work even if `obj` is nil, a number, a vector, anything like that. And in all of those
---cases, of course, it would return `false`.
---@param classDefinition ClassDefinition @Used with `obj:isInstanceOf(YourClass)` variant.
---@return boolean @True if argument is an instance of this class.
---@overload fun(): boolean
function _classBase:isInstanceOf(classDefinition) end

---Class method. Checks if class itself is a child class of a different class (or a child of a child, etc). 
---Can be used as `YourClass:isInstanceOf(YourOtherClass)`.
---@param classDefinition ClassDefinition @Class created by `class()` function.
---@return boolean @True if this class is a child of another class (or a child of a child, etc).
function _classBase:isSubclassOf(classDefinition) end

---Class method. Includes mixin, adding new methods to a preexising class. If mixin has a property `included`, it will be called
---with an argument referencing a class mixin is being added to. Can be used as `YourClass:include({ newMethod = function(self, arg) end })`.
---@param mixin ClassMixin @Any mixin.
function _classBase:include(mixin) end

---Class method. Creates a new child class.
---@return ClassDefinition @New class definition
function _classBase:subclass(...) end

---Class method. Called when a new child class is created using this class as a parent one. Redefine this function for
---your class if you need some advanced processing, like adding new methods to a child class.
---@param classDefinition ClassDefinition @New class definition
function _classBase:subclassed(classDefinition) end

---A base class for objects with pooling. Doesn’t add anything, but you can add it as a parent class
---so that `recycled()` would be documented.
---@class ClassPool : ClassBase
local _classPool = {}

---Called when object is about to get recycled.
---@return boolean @Return false if this object should not be recycled and instead destroyed as usual.
function _classPool:recycled() end

---Create a new class. Example:
---
---```
---local MyClass = class('MyClass')        -- class declaration
---
---function MyClass:initialize(arg1, arg2) -- constructor
---  self.myField = arg1 + arg2            -- field
---end
---
---function MyClass:doMyThing()            -- method
---  print(self.myField)
---end
---
---local instance = MyClass(1, 2)          -- creating instance of a class
---instance:doMyThing()                    -- calling a method
---```
---
---Whole thing is very similar to [middleclass](https://github.com/kikito/middleclass), but it’s a different
---implementation that should be somewhat faster. Main differences:
---
---1. Class name is stored in `YourClass.__name` instead of `YourClass.name`.
---
---2. There is no `.static` subtable, all static fields and methods are instead stored in main class
---   table and thus are available as instance fields and methods as well (that’s why `YourClass.name` was
---   renamed to `YourClass.__name`, to avoid possible confusion with a common field name). It’s a bit
---   messier, especially with class methods such as `:subclass()`, but it has some advantages as well:
---   objects creation is faster, and it’s more EmmyLua-friendly (both of which is what it’s all about).
---
---3. Overloaded `__tostring`, `__len` and `__call` are inherited, but not other operators.
---
---4. Method `YourClass.allocate()` works differently here and is used to create a simple table which will be
---   passed to `setmetatable()`. This can help with performance if objects are created often.
---
---Everything else should work the same, including inheritance and mixins. As for performance, some simple
---tests show up to 30% faster objects creation and 40% less memory used for objects with two fields when
---using `YourClass.allocate()` method instead of `YourClass:initialize()` (that alone gives about 15% increase in speed
---when creating an object with two fields):
---
---```
---function YourClass.allocate(arg1, arg2)  -- notice . instead of :
---  return { myField = arg1 + arg2 }     -- also notice, methods are not available at this stage
---end
---```
---
---Other differences (new features rather than something breaking compatibility) and important notes:
---
---1. Function `class()` takes string for class name, another class to act like a parent,
---   allocate and initialize functions and flags. Everything is optional and can go in any order (with one caveat:
---   allocate function should go before initialize function unless you’re using `class.Pool`). Generally there is no
---   benefit in passing allocate and initialize functions here though.
---
---2. With flag `class.NoInitialize` constructor would not look for `YourClass:initialize()` method to call at all,
---   instead using only `YourClass.allocate()`. Might speed things up a bit further.
---
---3. If you’re creating new instances really often, there is a `class.Pool` flag. It would disable the use of
---   `YourClass.allocate()`, but instead allow to reuse unused objects by using `class.recycle(object)`. Recycled objects
---   would end up in a pool of objects to be reused next time an instance would need to be created. Of course, it
---   introduces a whole new type of errors (imagine storing a reference to a recycled item somewhere not knowing it was
---   recycled and now represents something else entirely), so please be careful.
---
---   Note 1: Method `class.recycle()` can be used with nils or non-recycle, no need to have extra checks before calling it.
--- 
---   Note 2: Instances of child classes won’t end up in parent class pool. For such arrangements, consider adding pooling
---           flag to all of child classes where appropriate.
---
---4. Before recycling, method `YourClass:recycled()` will be called. Good time to recycle any inner elements. Also,
---   return `false` from it and object would not be recycled at all.
---
---5. To check type, `YourClass.isInstanceOf(item)` can also be used. Notice that it’s a static method, no “:” here.
---
---All classes are considered children classes of `ClassBase`, that one is mostly for EmmyLua to pick up methods like 
---`YourClass.isInstanceOf(object)`. If you’re creating your own class and want to use such methods, just add `: ClassBase`
---to its EmmyLua annotation. And objects with pooling are children of `ClassPool` which is a child of `ClassBase`. Note: 
---to speed things up, those classes aren’t fully real, but you can access them and their methods and even call things like
---`ClassBase:include()`. Please read documentation for those functions before using them though, just to check.
---@param name string @Class name.
---@param parentClass ClassBase @Parent class.
---@param flags nil | integer | 'class.NoInitialize' | 'class.Pool' | 'class.Minimal' @Flags.
---@overload fun(name: string, flags: nil | integer | 'class.NoInitialize' | 'class.Pool' | 'class.Minimal')  @Regular parent-less class with some flags
---@overload fun(name: string, allocateFn: function | `function() return {} end, class.NoInitialize`)    @Inline allocate function for slightly faster creation
---@overload fun(name: string, initializeFn: `function (self) end, class.Pool`)               @With pooling for best memory reuse
---@overload fun(allocateFn: `function() return {} end, class.NoInitialize + class.Minimal`)  @Most minimal version
---@return ClassDefinition @New class definition
function class(name, parentClass, flags) end

class = {}

---Skip initialization function completely. Might slightly speed up object creation.
class.NoInitialize = 1

---Reuse recycled objects instead of creating new ones. Disables `.allocate()` and switches to `:initialize()`,
---but performance gain from not having to allocate new tables is worth it. Don’t forget to recycle unused elements
---with `class.recycle(item)`.
class.Pool = 2

---Minimal version of a class, skips creation of all static methods and default to-string operators.
---
---To use with either pooling or no-initialize setup, pass two flags separated by a comma, or just sum them together
---(would work only if values are powers of two and you’re not summing together the same flag twice). Or, use
---`bit.bor(flag1, flag2)`, courtesy of LuaJIT and its BitOp extension.
class.Minimal = 4

---Recycle an item to its pool, to speed up creation and reduce work for GC. Requires class to be created with
---`class.Pool` flag.
---
---This method has protection from double recycling, recycling nils or non-recycleable items, so don’t worry about it.
---@param item ClassPool|nil
function class.recycle(item) end

---A trick to get `class()` to work with EmmyLua annotations nicely. Call `class.emmy(YourClass, YourClass.initialize)`
---or `class.emmy(YourClass, YourClass.allocate)` (whatever you’re using) and it would give you a constructor function.
---Then, use it for local reference or as a return value from module. For best results add annotations to function you’re
---passing here, such as return value or argument types.
---
---In reality is simply returns the class back and ignores second argument, but because of this definition EmmyLua thinks
---it got the constructor.
---@generic T1
---@generic T2
---@param classFn T1
---@param constructorFn T2
---@return T1|T2
function class.emmy(classFn, constructorFn) return constructorFn end