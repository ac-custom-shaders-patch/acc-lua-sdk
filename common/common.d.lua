---@meta

---Path to a folder with currently running script.
---@type string
__dirname = nil

---Main CSP namespace.
ac = {}

---FFI-accelerated list, acts like a regular list (consequent items, size and capacity, automatically growing, etc.)
---Doesn’t store nil values to act more like a Lua table.
---
---For slightly better performance it might be benefitial to preallocate memory with `list:reserve(expectedSizeOrABitMore)`.
---@class ac.GenericList
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
