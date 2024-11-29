__source 'lua/api_extras_connectmmf.cpp'

require('./ac_struct_item')

local function mmfGC(item)
  -- ac.log('GC: %p' % ffi.cast('uint64_t', item))
  ffi.gc(item, nil)
  ffi.C.lj_connectmmf_gc(ffi.cast('void*', item))
end

---Opens shared memory file for reading. Do not attempt to modify any of its contents: doing so pretty much always would result in Assetto Corsa
---just straight up crashing.
---@generic T
---@param filename string @Shared memory file filename (without “Local\” bit).
---@param layout T @String for the body of the structure.
---@param persist boolean? @Keep file alive even after the script stopped or the variable was cleared by garbage collector. Default value: `false`.
---@return T
---@overload fun(filename: string, layout: string, persist: boolean?): any
function ac.readMemoryMappedFile(filename, layout, persist)
  if not __allowIO__ and not string.startsWith(filename, 'AcTools.CSP.Limited.') then error('Script of this type can’t access shared memory files', 2) end

  local ret
  if type(layout) == 'number' then
    if persist then
      error('Option “persist” is not available with raw files', 2)
    end
    ret = ffi.C.lj_connectmmf_new(filename, layout, false)
    if ret == nil then error('Failed to open shared memory file', 2) end
  else
    local s_name = __util.__si_ffi(layout, false)
    local ptr = ffi.C.lj_connectmmf_new(filename, ffi.sizeof(s_name), false)
    if ptr == nil then error('Failed to open shared memory file', 2) end
    ret = ffi.cast(ffi.typeof(s_name..'*'), ptr)
  end

  if not persist then ret = ffi.gc(ret, mmfGC) end
  return __util.__si_proxy(layout, ret)
end

---Opens shared memory file for writing. Note: if the file would exist at the moment of opening (for example, created before by a different
---Lua script, or by a separate process), it would retain its current state, but if it’s a new file, it’ll be initialized with all zeroes.
---@generic T
---@param filename string @Shared memory file filename (without “Local\” bit).
---@param layout T @String for the body of the structure.
---@param persist boolean? @Keep file alive even after the script stopped or the variable was cleared by garbage collector. Default value: `false`.
---@return T
---@overload fun(filename: string, layout: string, persist: boolean?): any
function ac.writeMemoryMappedFile(filename, layout, persist)
  if not __allowIO__ and not string.startsWith(filename, 'AcTools.CSP.Limited.') then error('Script of this type can’t access shared memory files', 2) end

  local ret
  if type(layout) == 'number' then
    if persist then
      error('Option “persist” is not available with raw files', 2)
    end
    ret = ffi.C.lj_connectmmf_new(filename, layout, true)
    if ret == nil then error('Failed to open shared memory file', 2) end
  else
    local s_name = __util.__si_ffi(layout, false)    
    local ptr = ffi.C.lj_connectmmf_new(filename, ffi.sizeof(s_name), true)
    if ptr == nil then error('Failed to open shared memory file', 2) end  
    ret = ffi.cast(ffi.typeof(s_name..'*'), ptr)
  end

  if not persist then ret = ffi.gc(ret, mmfGC) end
  return __util.__si_proxy(layout, ret)
end

---Forcefully closes memory mapped file opened either for reading or writing without waiting for GC to pick it up.
function ac.disposeMemoryMappedFile(reference)
  if type(reference) == 'table' and reference.__data_cdata__ then
    reference = reference.__data_cdata__.i
  end
  if type(reference) == 'cdata' then
    -- ac.log('DISPOSE: %p' % ffi.cast('uint64_t', reference))
    mmfGC(reference)
  end
end
