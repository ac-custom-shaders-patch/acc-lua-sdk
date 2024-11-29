__script = {}

---Disposable thing is something set which you can then un-set. Just call `ac.Disposable` returned
---from a function to cancel out whatever happened there. For example, unsubscribe from an event.
---@alias ac.Disposable fun()

---Calls a function in a safe way, catching errors. If any errors were to occur, `catch` would be
---called with an error message as an argument. In either case (with and without error), if provided,
---`finally` will be called.
---
---Does not raise errors unless errors were thrown by `catch` or `finally`. Before CSP 0.2.5, if `catch`
---throws an error, `finally` wouldn’t be called (fixed in 0.2.5).
---@generic T
---@param fn fun(): T?
---@param catch fun(err: string)|nil @If not set, error won’t propagate anyway.
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
    if catch ~= nil then
      ranFine, result = pcall(catch, result)
      if finally ~= nil then finally() end
      if not ranFine then
        error(result, 1)
      end
    elseif finally ~= nil then
      return finally()
    end
  end
end

---Calls a function and then calls `dispose` function. Note: `dispose` function will be called even if
---there would be an error in `fn` function. But error would not be contained and will propagate.
---
---Any error thrown by `fn()` will be raised and not captured, but `dispose()` will be called either way.
---@generic T
---@param fn fun(): T?
---@param dispose fun()? @CSPs before 0.2.5 require non-nil argument.
---@return T|nil
function using(fn, dispose)
  local r1, r2, r3
  if not dispose then
    r1, r2, r3 = fn()
  else
    __util.pushEnsureToCall(dispose)
    r1, r2, r3 = fn()
    __util.popEnsureToCall()
  end
  return r1, r2, r3
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

---Given an FFI struct and a string of data, fills struct with that data. Works only if size of struct matches size of data. Data string can contain zeroes.
---@generic T
---@param destination T @FFI struct (type should be “cdata”).
---@param data binary @String with binary data.
---@return T
function ac.fillStructWithBytes(destination, data)
  if type(destination) == 'table' and destination.__data_cdata__ then destination = destination.__data_cdata__.i end
  if type(destination) ~= 'cdata' then error('Can get bytes from cdata only', 2) end
  if type(data) ~= 'string' then error('Data should be a string', 2) end
  local s = ffi.sizeof(destination)
  if s == 8 and string.find(tostring(ffi.typeof(destination)), '*', 1, false) then error('Can’t be used with pointers', 2) end
  ffi.C.lj_fillStructWithBytes_inner(destination, s, __util.blob(data))
  return destination
end

---Fills a string of an FFI struct with data up to a certain size. Make sure to not overfill the data.
---@param src string @String to copy.
---@param dst string @A `const char[N]` field of a struct.
---@param size integer @Size of `const char[N]` field (N). 
function ac.stringToFFIStruct(src, dst, size)
  if not string.find(tostring(ffi.typeof(dst)), 'char', 1, false) then error('Can’t be used with something other than a string', 2) end
  ffi.C.lj_stringToFFIStruct_inner(src, dst, size)
end

do

local _cdfl = {}

---Returns ordered list of data file names (not full paths, just the names) of a certain car. Works for both packed and unpacked cars. If failed,
---returns empty list.
---@param index integer @0-based car index.
---@return string[]
function ac.getCarDataFiles(index)
  local k = 1e3 + index
  if not _cdfl[k] then _cdfl[k] = __util.native('ac.getCarDataFiles', tonumber(index) or 0) or {} end
  return _cdfl[k]
end

---Returns list of car colliders.
---@param index integer @0-based car index.
---@param actualColliders boolean? @Set to `true` to draw actual physics colliders (might differ due to some physics alterations).
---@return {position: vec3, size: vec3}[]
function ac.getCarColliders(index, actualColliders)
  local k = 2e3 + index + (actualColliders and 0.5 or 0)
  if not _cdfl[k] then _cdfl[k] = __util.native('ac.getCarColliders', tonumber(index) or 0, actualColliders) or {} end
  return _cdfl[k]
end

end