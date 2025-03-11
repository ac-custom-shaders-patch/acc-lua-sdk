---@meta

---Path to a folder with currently running script.
---@type string
__dirname = nil

---A filename, either absolute or relative. If relative, will be resolved against AC root folder. Use `os.setCurrentFolder()` to change current folder.
---@alias path string

---Could be either a string, a number or a boolean value (will be converted into string).
---String can store any binary data including zero bytes. Could also be an FFI struct and it will
---be processed as its binary form.
---@alias binary string|number|boolean

---Could be either a string, a number, a boolean value or a table (without circular references or any non-serializable
---items). Will be serialized here and deserialized in a different script. String can store any binary data including zero bytes.
---@alias serializable string|number|boolean|table|nil

---Main CSP namespace.
ac = {}

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

---Return an element at given index.
---@param index integer @1-based index.
---@return any
function _ac_genericList:get(index) end

---Sets an element at given index.
---@param index integer @1-based index.
---@param value any 
function _ac_genericList:set(index, value) end

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

--[[? if (!ctx.flags.withPhysics) out(]]

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

---@param destination any
---@param data any|string
---@param size integer?
function ffi.copy(destination, data, size) end

---Namespace only available for background workers. Use `ac.startBackgroundWorker()` to start a background worker.
worker = {}

---Input data passed to a worker during launch.
---@type nil|boolean|number|string|table
worker.input = nil

---Input data passed to a worker during launch.
---@type nil|boolean|number|string|table
worker.input = nil

---Available only in background worker scripts. Sleep function pauses execution for a certain time. 
---Before unpaused, any callbacks (such as `setTimeout()`, `setInterval()` and
---other custom enqueued callbacks) will be called. This is the only way for those callbacks to fire in a background worker. Note:
---if parent thread is closed, `worker.sleep()` won’t return back and instead script will be unloaded, this way worker can be reloaded
---as well.
---
---If your worker does a lot of async operations, consider using `worker.wait()` instead, setting resulting value with `worker.result`.
---Or maybe not even use anything at all: for basic (non-repeating) callbacks, timers and intervals script will continue running until
---all the postponed actions are complete (updating once every 100 ms).
---@param time number @Time in seconds to pause worker by.
function worker.sleep(time) end

---Wait for `worker.result` value to be set. Stops the worker once `worker.result` value has been provided (or any `error()` has been raised).
---Works the best if your worker uses a lot of async operations. 
---@param time number? @Time in seconds for timeout. Default value: 60. Feel free to pass something like `math.huge` if you don’t need timeout for some reason.
function worker.wait(time) end

---Resulting value used when using `worker.wait()`.
---@type nil|boolean|number|string|table
worker.result = nil

--[[) ?]]
