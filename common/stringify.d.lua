---Serialize Lua value (table, number, string, etc.) in a Lua table format (similar to how `JSON.stringify` in JavaScript
---generates a thing with JavaScript syntax). Format seems to be called Luaon. Most of Lua entities are supported, including array-like tables, table
---tables and mixed ones. CSP API things, such as vectors or colors, are also supported. For things like threads,
---functions or unknown cdata types instead a placeholder object will be created.
---
---Circular references also result in creating similar objects, for example: `t = {1, 2, 3, t}` would result in
---`{ 1, 2, 3, { type = 'circular reference' } }`.
---
---If any table in given data would have a `__stringify()` function, it would be called as a method (so first argument
---would be the table with `__stringify` itself). If that function would return a string, that string will be used
---instead of regular table serialization. The idea is for classes to define a method like this and output a line of code
---which could be used to create a new instance like this on deserialization. Note: for such like to use a custom function
---like a class constructor, you would either need to register that function with a certain name or provide a table referring
---to it on deserialization. That’s because although deserialization uses `load()` function to parse and run data as Lua code,
---it wouldn’t allow code to access existing functions by default.
---@param obj table|number|string|boolean|nil @Object o serialize.
---@param compact boolean? @If true, resulting string would not have spaces and line breaks, slightly faster and a lot more compact.
---@param depthLimit integer? @Limits how deep serialization would go. Default value: 20.
---@return string @String with input data presented in Lua syntax.
function stringify(obj, compact, depthLimit) end

---Parse a string with Lua table syntax into a Lua object (table, number, string, vector, etc.), can support custom objects as well.
---Only functions from `namespace` can be used (as well as vectors and functions registered earlier with `stringify.register()`),
---so if you’re using custom classes, make sure to either register them earlier or pass them in `namespace` table. Alternatively,
---you can just pass `_G` as `namespace`, but it might be pretty unsecure, so maybe don’t do it.
---
---Would raise an error if failed to parse or if any of initializers would raise an error.
---@param serialized string @Serialized data.
---@param namespace table<string, function>|nil @Namespace table. Serialized data would be evaluated as Lua code and would have access to it.
---@return table|number|string|boolean|nil
function stringify.parse(serialized, namespace) end

---Parse a string with Lua table syntax into a Lua object (table, number, string, vector, etc.), can support custom objects as well.
---Only functions from `namespace` can be used (as well as vectors and functions registered earlier with `stringify.register()`),
---so if you’re using custom classes, make sure to either register them earlier or pass them in `namespace` table. Alternatively,
---you can just pass `_G` as `namespace`, but it might be pretty unsecure, so maybe don’t do it.
---
---Returns fallback value if failed to parse, or if `serialized` is empty or not set, or if any of initializers would raise an error.
---@generic T
---@param serialized string @Serialized data.
---@param namespace table<string, function>|nil @Namespace table. Serialized data would be evaluated as Lua code and would have access to it.
---@param fallback T|nil @Value to return if parsing failed.
---@return T
function stringify.tryParse(serialized, namespace, fallback) end

---Registers a new initializer function with a given name.
---@param name string @Name of an initializer (how serialized data would refer to it).
---@param fn function @Initializer function (returning value for serialized data to use).
---@overload fun(class: ClassDefinition)
function stringify.register(name, fn) end

---Serialization substep. Works similar to `stringify()` itself, but instead of returning string simply adds new terms to
---`out` table. Use it in custom `__stringify` methods for serializing child items if you need the best performance.
---@param out string[] @Output table with words to concatenate later (without any joining string).
---@param ptr integer @Position within `out` table to write next word into. At the very start, when table is empty, it would be 1.
---@param obj any @Item to serialize.
---@param lineBreak string|nil @Line break with some spaces for aligning child items, or `nil` if compact stringify mode is used. One tab is two spaces.
---@param depthLimit integer @Limits how many steps down serialization can go. If 0 or below, no tables would be serialized.
---@return integer @Updated `ptr` value (if one item was added to `out`, should increase by 1).
function stringify.substep(out, ptr, obj, lineBreak, depthLimit) end

---A small helper to add as a parent class for EmmyLua to work better.
---@class ClassStringifiable : ClassBase
local _classStringifiable = {}

---Serialize instance of class. Can either return a `string`, or construct it into `out` table and return a new position in it. String itself should be a like of
---Lua code which would reconstruct the object on deserialization. Don’t forget to either register referred function with `stringify.register()` or provide
---a reference to it in `namespace` table with `stringify.parse()`.
---
---Note: to serialize sub-objects, such as constructor arguments, you can use `stringify()` or `stringify.substep()` if you’re using an approach with
---manually constructing `out` table. Alternatively for basic types you can use `string.format()`: “%q” would give you a string in Lua format, so you can use it
---like so:
---```
---function MyClass:__serialize()
---  return string.format('MyClass(%q, %s)', self.stringName, self.numericalCounter)
---end
---```
---@param out string[] @Output table with words to concatenate later (without any joining string).
---@param ptr integer @Position within `out` table to write next word into. At the very start, when table is empty, it would be 1.
---@param obj any @Item to serialize.
---@param lineBreak string|nil @Line break with some spaces for aligning child items, or `nil` if compact stringify mode is used. One tab is two spaces.
---@param depthLimit integer @Limits how many steps down serialization can go. If 0 or below, no tables would be serialized.
---@return integer @Updated `ptr` value (if one item was added to `out`, should increase by 1).
---@overload fun(): string @Simpler version which should work well in 98% of times. Use a more detailed one only if you have a ton of objects and need to improve performance.
function _classStringifiable:__stringify(out, ptr, obj, lineBreak, depthLimit) end
