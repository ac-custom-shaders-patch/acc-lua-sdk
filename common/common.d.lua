---@meta

---Path to a folder with currently running script.
---@type string
__dirname = nil

---Could be either a string, a number or a boolean value (will be converted into string).
---String can store any binary data including zero bytes. Could also be an FFI struct and it will
---be processed as its binary form.
---@alias binary string|number|boolean

---Could be either a string, a number, a boolean value or a table (without circular references or any non-serializable
---items). Will be serialized here and deserialized in a different script. String can store any binary data including zero bytes.
---@alias serializable string|number|boolean|table|nil

---Main CSP namespace.
ac = {}

---Get car tags. If there is no such car, returns `nil`.
---@param carIndex integer @0-based car index.
---@return string[]?
function ac.getCarTags(carIndex) end

---FFI-accelerated list, acts like a regular list (consequent items, size and capacity, automatically growing, etc.)
---Doesn’t store nil values to act more like a Lua table.
---
---Few notes:
---• Use `:get()` and `:set()` to access elements instead of square brakets;
---• Indices are 1-based;
---• For fastest access to individual elements use `.raw` field: it’s a raw pointer, so use 0-based indices there and
---make sure not to access things outside of list size.
---
---For slightly better performance it might be benefitial to preallocate memory with `list:reserve(expectedSizeOrABitMore)`.
---@class ac.GenericList
---@field raw any @Raw pointer for fastest unchecked access with 0-based indices. Use very carefully!
local _ac_genericList = {}

---Number of items in the list.
---@return integer
function _ac_genericList:size() end

---Size of list in bytes (not capacity, for that use `list:capacityBytes()`).
---@return integer
function _ac_genericList:sizeBytes() end

---Checks if list is empty.
---@return boolean
function _ac_genericList:isEmpty() end

---Capacity of the list.
---@return integer
function _ac_genericList:capacity() end

---Size of list in bytes (capacity).
---@return integer
function _ac_genericList:capacityBytes() end

---Makes sure list can fit `newSize` of elements without reallocating memory.
---@param newSize integer
---@return integer
function _ac_genericList:reserve(newSize) end

---If capacity is greater than current size, reallocates a smaller bit of memory and moves data there.
function _ac_genericList:shrinkToFit() end

---Removes all elements.
function _ac_genericList:clear() end

---Creates a new list with the same contents as the existing one.
---@return ac.GenericList
function _ac_genericList:clone() end

---Custom FFI namespace. Be very careful around here.
---@class ffilibex
---@field C nil @Avoid using functions directly.
ffi = {}

---@param def     string
---@param params? any
function ffi.cdef(def, params, ...) end

---@param ct  ffi.ct*
---@param obj any
---@return boolean
---@nodiscard
function ffi.istype(ct, obj) end

---@param ptr  any
---@param len? integer
---@return string
function ffi.string(ptr, len) end

---@param ct      ffi.ct*
---@param params? any
---@return ffi.ctype*
---@nodiscard
function ffi.typeof(ct, params, ...) end

---@param ct   ffi.ct*
---@param init any
---@return ffi.cdata*
---@nodiscard
function ffi.cast(ct, init) end

---@param ct        ffi.ct*
---@param metatable table
---@return ffi.ctype*
function ffi.metatype(ct, metatable) end

---@param cdata     ffi.cdata*
---@param finalizer? function
---@return ffi.cdata*
function ffi.gc(cdata, finalizer) end
