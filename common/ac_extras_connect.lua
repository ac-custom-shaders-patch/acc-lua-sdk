__source 'lua/api_extras_connect.cpp'

require('./ac_struct_item')

---Creates a new shared structure to quickly exchange data between different Lua scripts within a session. Example:
---```
---local sharedData = ac.connect{
---  ac.StructItem.key('myChannel'),        -- optional, to avoid collisions
---  someString = ac.StructItem.string(24), -- 24 is for capacity
---  someInt = ac.StructItem.int(),
---  someDouble = ac.StructItem.double(),
---  someVec = ac.StructItem.vec3()
---}
---```
---
---Note: to connect two scripts, both of them chould use `ac.connect()` and pass exactly the same layouts. Also, consider using more
---specific names to avoid possible unwanted collisions. For example, instead of using `value = ac.StructItem.int()` which might be
---used somewhere else, use `weatherBrightnessValue = ac.StructItem.int()`. Or, simply add `ac.StructItem.key('myUniqueKey')`.
---
---For safety reasons, car scripts can only connect to other car scripts, and track scripts can only connect to other track scripts.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Alternatively, you can pass a string for the body of the structure here, but be careful with it.
---@param keepLive boolean? @Set to true to keep structure even if any references were removed or script was unloaded.
---@param namespace nil|ac.SharedNamespace @Optional namespace stopping scripts of certain types to access data of scripts with different types. For more details check `ac.SharedNamespace` documentation.
---@return T
function ac.connect(layout, keepLive, namespace)
  if not __allowIO__ and namespace == ac.SharedNamespace.Global then error('Script of this type can’t use global namespace', 2) end
  local s_name, s_layout = __util.__si_ffi(layout, false)
  local s_size = ffi.sizeof(s_name)
  return __util.__si_proxy(layout, ffi.gc(ffi.cast(s_name..'*', 
    ffi.C.lj_connect_new(s_layout, type(namespace) == 'string' and namespace or nil, s_size, keepLive ~= false)), ffi.C.lj_connect_gc))
end

---Create a new struct from a given layout. Could be used in calls like `ac.structBytes()` and `ac.fillStructWithBytes()`. Each call defines and creates a new struct, so don’t
---call them each frame, I believe LuaJIT doesn’t do garbage collection on struct definitions.
---@generic T
---@param layout T
---@param compact boolean?
---@return T
---@return integer @Structure size.
---@return string @Structure name.
function ac.StructItem.combine(layout, compact)
  local s_name = __util.__si_ffi(layout, compact)
  return ffi.new(s_name), ffi.sizeof(s_name), s_name
end
