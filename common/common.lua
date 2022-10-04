__script = {}

---Disposable thing is something set which you can then un-set. Just call `ac.Disposable` returned
---from a function to cancel out whatever happened there. For example, unsubscribe from an event.
---@alias ac.Disposable fun()

---For better compatibility, acts like `ac.log()`.
function print(v) ac.log(v) end

---Not doing anything anymore, kept for compatibility.
---@deprecated
function ac.skipSaneChecks() end

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
---@param fn fun(): T
---@param dispose fun()
---@return T|nil
function using(fn, dispose)
  __util.pushEnsureToCall(dispose)
  local r1,r2,r3 = fn()
  __util.popEnsureToCall()
  return r1,r2,r3
end

---Stores value in session shared Lua/Python storage. This is not a long-term storage, more of a way for
---different scripts to exchange data. Note: if you need to exchange a lot of data between Lua scripts,
---consider using ac.connect instead.
---
---Data string can contain zeroes.
---@param key string
---@param value string|number
function ac.store(key, value)
  key = tostring(key or "")
  if type(value) == 'number' then
    ffi.C.lj_store_number(key, value)
  else
    ffi.C.lj_store_string(key, __util.blob(value))
  end
end

---Reads value from session shared Lua/Python storage. This is not a long-term storage, more of a way for
---different scripts to exchange data. Note: if you need to exchange a lot of data between Lua scripts,
---consider using ac.connect instead.
---@param key string
---@return nil|string|number
function ac.load(key)
  key = tostring(key or "")
  if ffi.C.lj_has_number(key) then
    return ffi.C.lj_load_number(key)
  else
    return __util.strrefp(ffi.C.lj_load_string(key))
  end
end

local releaseCallbacks = {}

---Adds a callback which might be called when script is unloading. Use it for some state reversion, but
---don’t rely on it too much. For example, if Assetto Corsa would crash or just close rapidly, it would not
---be called. It should be called when scripts reload though.
function ac.onRelease(callback)
  table.insert(releaseCallbacks, callback)
end

function __script.release()
  for i = 1, #releaseCallbacks do
    releaseCallbacks[i]()
  end
end

---For easy import of scripts from subdirectories. Provide it a name of a directory relative
---to main script folder and it would add that directory to paths it searches for.
---@param dir string
function package.add(dir)
  package.path = package.path .. ';' .. __dirname .. '/' .. dir .. '/?.lua'
  package.cpath = package.cpath .. ';' .. __dirname .. '/' .. dir .. '/?.dll'
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
---@return string|nil @If data is `nil`, returns `nil`.
function ac.structBytes(data)
  if type(data) ~= 'cdata' then error('Can get bytes from cdata only', 2) end
  return __util.strrefp(ffi.C.lj_structBytes_inner(data, ffi.sizeof(data)))
end

---Given an FFI struct and a string of data, fills struct with that data. Works only if size of struct matches size of data. Data string can contain zeroes.
---@generic T
---@param destination T @FFI struct (type should be “cdata”).
---@param data string @String with binary data.
---@return T
function ac.fillStructWithBytes(destination, data)
  if type(destination) ~= 'cdata' then error('Can get bytes from cdata only', 2) end
  if type(data) ~= 'string' then error('Data should be a string', 2) end
  ffi.C.lj_fillStructWithBytes_inner(destination, ffi.sizeof(destination), __util.blob(data))
  return destination
end
