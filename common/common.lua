__script = {}

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
---@param finally fun()
---@return T|nil
function try(fn, catch, finally)
  if not fn then 
    return finally()
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

local __toDispose, __toDisposeN = {}, 0
function __script.handleError()
  for i = __toDisposeN, 1, -1 do
    __toDispose[i]()
  end
  __toDisposeN = 0
end

---Calls a function and then calls `dispose` function. Note: `dispose` function will be called even if
---there would be an error in `fn` function. But error would not be contained and will propagate.
---@generic T
---@param fn fun(): T
---@param dispose fun()
---@return T|nil
function using(fn, dispose)
  if dispose == nil then return fn() end

  __toDisposeN = __toDisposeN + 1
  __toDispose[__toDisposeN] = dispose
  local r = fn()
  dispose()
  __toDisposeN = __toDisposeN - 1
  return r

  -- local s, r = pcall(fn)
  -- dispose()
  -- if not s then error(r, 1) end
  -- return r
end

---Stores value in session shared Lua/Python storage. This is not a long-term storage, more of a way for
---different scripts to exchange data. Note: if you need to exchange a lot of data between Lua scripts,
---consider using ac.connect instead.
---@param key string
---@param value string|number
function ac.store(key, value)
  key = tostring(key or "")
  if type(value) == 'number' then
    ffi.C.lj_store_number(key, value)
  else
    ffi.C.lj_store_string(key, value ~= nil and tostring(value) or nil)
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
    return __util.strref(ffi.C.lj_load_string(key))
  end
end

---For easy import of scripts from subdirectories. Provide it a name of a directory relative
---to main script folder and it would add that directory to paths it searches for.
---@param dir string
function package.add(dir)
  package.path = package.path .. ';' .. __dirname .. '/' .. dir .. '/?.lua'
end
