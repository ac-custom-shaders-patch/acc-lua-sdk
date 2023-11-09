__source 'lua/api_extras_connectmmf.cpp'

require('./ac_struct_item')

local _fficdef = ffi.cdef

local mmfc

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
---@param persist boolean? @Keep file alive even after the script stopped or the variable was cleared by garbage collector. Default value: `false`. Default value: `false`.
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
    local layoutStr = ac.StructItem.__build(layout)
    if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end

    if not mmfc then mmfc = {} end
    local cached = mmfc[layoutStr]
    if not cached then
      local name = '__cmm_'..tostring(ffi.C.lj_connectmmf_key())
      _fficdef(ac.StructItem.__cdef(name, layoutStr, false))
      cache = {ffi.sizeof(name), ffi.typeof(name..'*')}
      mmfc[layoutStr] = cache
      -- ac.log('New MMF struct (R)', cache[1], cache[2], filename)
    else
      -- ac.warn('Reuse MMF struct (R)', cache[1], cache[2], filename)
    end

    local ptr = ffi.C.lj_connectmmf_new(filename, cache[1], false)
    if ptr == nil then error('Failed to open shared memory file', 2) end
    ret = ffi.cast(cache[2], ptr)
  end

  if not persist then ret = ffi.gc(ret, mmfGC) end
  return ac.StructItem.__proxy(layout, ret)
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
    local layoutStr = ac.StructItem.__build(layout)
    if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end

    if not mmfc then mmfc = {} end
    local cached = mmfc[layoutStr]
    if not cached then
      local name = '__cmm_'..tostring(ffi.C.lj_connectmmf_key())
      _fficdef(ac.StructItem.__cdef(name, layoutStr, false))
      cache = {ffi.sizeof(name), ffi.typeof(name..'*')}
      mmfc[layoutStr] = cache
      -- ac.warn('New MMF struct (W)', cache[1], cache[2], filename)
    else
      -- ac.warn('Reuse MMF struct (W)', cache[1], cache[2], filename)
    end
    
    local ptr = ffi.C.lj_connectmmf_new(filename, cache[1], true)
    if ptr == nil then error('Failed to open shared memory file', 2) end  
    ret = ffi.cast(cache[2], ptr)
  end

  if not persist then ret = ffi.gc(ret, mmfGC) end
  return ac.StructItem.__proxy(layout, ret)
end

---Forcefully closes memory mapped file opened either for reading or writing without waiting for GC to pick it up.
function ac.disposeMemoryMappedFile(reference)
  if type(reference) == 'table' and reference.__data then
    reference = reference.__data.i
  end
  if type(reference) == 'cdata' then
    -- ac.log('DISPOSE: %p' % ffi.cast('uint64_t', reference))
    mmfGC(reference)
  end
end
