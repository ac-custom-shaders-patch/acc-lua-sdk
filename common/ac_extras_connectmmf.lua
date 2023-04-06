__source 'lua/api_extras_connectmmf.cpp'

require('./ac_struct_item')

local _fficdef = ffi.cdef

---Opens shared memory file for reading.
---@generic T
---@param filename string @Shared memory file filename (without “Local\” bit).
---@param layout T @String for the body of the structure.
---@return T
---@overload fun(filename: string, layout: string): any
function ac.readMemoryMappedFile(filename, layout)
  if not __allowIO__ then error('Script of this type can’t access shared memory files', 2) end
  local layoutStr = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end
  if layoutStr:match('%(') then error('Invalid layout', 2) end

  local name = '__cmm_'..tostring(ffi.C.lj_connectmmf_key())
  _fficdef(ac.StructItem.__cdef(name, layoutStr, false))
  local size = ffi.sizeof(name)

  local ptr = ffi.C.lj_connectmmf_new(filename, size, false)
  if ptr == nil then error('Failed to open shared memory file', 2) end

  return ac.StructItem.__proxy(layout, ffi.gc(ffi.cast(name..'*', ptr), ffi.C.lj_connectmmf_gc))
end

---Opens shared memory file for writing.
---@generic T
---@param filename string @Shared memory file filename (without “Local\” bit).
---@param layout T @String for the body of the structure.
---@return T
---@overload fun(filename: string, layout: string): any
function ac.writeMemoryMappedFile(filename, layout)
  if not __allowIO__ then error('Script of this type can’t access shared memory files', 2) end
  local layoutStr = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end
  if layoutStr:match('%(') then error('Invalid layout', 2) end

  local name = '__cmm_'..tostring(ffi.C.lj_connectmmf_key())
  _fficdef(ac.StructItem.__cdef(name, layoutStr, false))
  local size = ffi.sizeof(name)
  
  local ptr = ffi.C.lj_connectmmf_new(filename, size, true)
  if ptr == nil then error('Failed to open shared memory file', 2) end

  return ac.StructItem.__proxy(layout, ffi.gc(ffi.cast(name..'*', ptr), ffi.C.lj_connectmmf_gc))
end
