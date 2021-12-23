__source 'lua/api_extras_connect.cpp'

require('./ac_struct_item')

local _sizes = {}
local _fficdef = ffi.cdef

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
---@param keepLive boolean @Set to true to keep structure even if any references were removed or script was unloaded.
---@return T
function ac.connect(layout, keepLive)
  local layoutStr = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end
  if layoutStr:match('%(') then error('Invalid layout', 2) end
  local name = '__con_'..__util.strref(ffi.C.lj_connect_key(layoutStr))
  local size = _sizes[name]
  if size == nil then
    _fficdef(ac.StructItem.__cdef(name, layoutStr, false))
    size = ffi.sizeof(name)
    _sizes[name] = size
  end
  return ac.StructItem.__proxy(layout, ffi.gc(ffi.cast(name..'*', ffi.C.lj_connect_new(layoutStr, size, keepLive ~= false)), ffi.C.lj_connect_gc))
end
