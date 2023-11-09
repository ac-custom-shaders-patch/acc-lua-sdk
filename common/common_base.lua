__script = {}

---Disposable thing is something set which you can then un-set. Just call `ac.Disposable` returned
---from a function to cancel out whatever happened there. For example, unsubscribe from an event.
---@alias ac.Disposable fun()

---For better compatibility, acts like `ac.log()`.
function print(...) ac.log(...) end

---Calls a function in a safe way, catching errors. If any errors were to occur, `catch` would be
---called with an error message as an argument. In either case (with and without error), if provided,
---`finally` will be called.
---@generic T
---@param fn fun(): T
---@param catch fun(err: string)
---@param finally fun()|nil
---@return T|nil
function try(fn, catch, finally)
  if not fn then 
    return finally ~= nil and finally()
  end
  local ranFine, result = pcall(fn)
  if ranFine then
    if finally ~= nil then finally() end
    return result
  else
    if catch ~= nil then catch(result) end
    if finally ~= nil then return finally() end
  end
end

---Calls a function and then calls `dispose` function. Note: `dispose` function will be called even if
---there would be an error in `fn` function. But error would not be contained and will propagate.
---@generic T
---@param fn fun(): T?
---@param dispose fun()
---@return T|nil
function using(fn, dispose)
  __util.pushEnsureToCall(dispose)
  local r1,r2,r3 = fn()
  __util.popEnsureToCall()
  return r1,r2,r3
end

local _dbg = debug.getinfo

---Resolves relative path to a Lua module (relative to Lua file you’re running this function from)
---so it would be ready to be passed to `require()` function.
---
---Note: performance might be a problem if you are calling it too much, consider caching the result.
---@param path string
---@return string
function package.relative(path)
  return '.'.._dbg(2).source:sub(#__dirname + 2):match('.*[/\\\\]')..path
end

---Resolves relative path to a file (relative to Lua file you’re running this function from)
---so it would be ready to be passed to `io` functions (returns full path).
---
---Note: performance might be a problem if you are calling it too much, consider caching the result.
---@param path string
---@return string
function io.relative(path)
  return _dbg(2).source:sub(2):match('.*[/\\\\]')..path
end

---Given an FFI struct, returns bytes with its content. Resulting string may contain zeroes.
---@param data any @FFI struct (type should be “cdata”).
---@return binary|nil @If data is `nil`, returns `nil`.
function ac.structBytes(data)
  if type(data) == 'table' and data.__data then data = data.__data.i end
  if type(data) ~= 'cdata' then error('Can get bytes from cdata only', 2) end
  return __util.strrefp(ffi.C.lj_structBytes_inner(data, ffi.sizeof(data)))
end

---Given an FFI struct and a string of data, fills struct with that data. Works only if size of struct matches size of data. Data string can contain zeroes.
---@generic T
---@param destination T @FFI struct (type should be “cdata”).
---@param data binary @String with binary data.
---@return T
function ac.fillStructWithBytes(destination, data)
  if type(destination) == 'table' and destination.__data then destination = destination.__data.i end
  if type(destination) ~= 'cdata' then error('Can get bytes from cdata only', 2) end
  if type(data) ~= 'string' then error('Data should be a string', 2) end
  ffi.C.lj_fillStructWithBytes_inner(destination, ffi.sizeof(destination), __util.blob(data))
  return destination
end

---Fills a string of an FFI struct with data up to a certain size. Make sure to not overfill the data.
---@param src string @String to copy.
---@param dst string @A `const char[N]` field of a struct.
---@param size integer @Size of `const char[N]` field (N). 
function ac.stringToFFIStruct(src, dst, size)
  ffi.C.lj_stringToFFIStruct_inner(src, dst, size)
end

local _cdfl

---Returns ordered list of data file names (not full paths, just the names) of a certain car. Works for both packed and unpacked cars. If failed,
---returns empty list.
---@param index integer @0-based car index.
---@return string[]
function ac.getCarDataFiles(index)
  if not _cdfl then
    ffi.C.lj_getCarDataFiles_inner(tonumber(index) or 0)
    _cdfl = __util.result() or {}
  end
  return _cdfl
end
