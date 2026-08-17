-- API available to all scripts (but not available within `const()` preprocessing).

ac.skipSaneChecks = function() end

do

local releaseCallbacks = nil

local function preventReleaseCallback(callback)
  table.removeItem(releaseCallbacks, callback)
end

---Adds a callback which might be called when script is unloading. Use it for some state reversion, but
---don’t rely on it too much. For example, if Assetto Corsa would crash or just close rapidly, it would not
---be called. It should be called when scripts reload though.
---@generic T
---@param callback fun(item: T)
---@param item T? @Optional parameter. If provided, will be passed to callback on release, but stored with a weak reference, so it could still be GCed before that (in that case, callback won’t be called at all).
---@return fun() @Call to disable callback.
function ac.onRelease(callback, item)
  if item then
    local callbackBak, store = callback, setmetatable({item}, {__mode = 'v'})
    callback = function ()
      if store[1] then callbackBak(store[1]) end
    end
  end
  if not releaseCallbacks then releaseCallbacks = {} end
  table.insert(releaseCallbacks, callback)
  return function ()
    preventReleaseCallback(callback)
  end
end

function __script.release()
  if releaseCallbacks then
    local p = {}
    preventReleaseCallback = function (callback)
      table.insert(p, callback)
    end
    for i = 1, #releaseCallbacks do
      if not table.contains(p, releaseCallbacks[i]) then
        local s, err = pcall(releaseCallbacks[i])
        if not s then
          ac.warn('onRelease exception: '..tostring(err))
          ffi.C.lj_critical_assert()
        end
      end
    end
  end
end

end

---For easy import of scripts from subdirectories. Provide it a name of a directory relative
---to main script folder and it would add that directory to paths it searches for.
---@param dir string
function package.add(dir)
  package.path = package.path .. ';' .. __dirname .. '/' .. dir .. '/?.lua'
  package.cpath = package.cpath .. ';' .. __dirname .. '/' .. dir .. '/?.dll'
end

---Sets a callback which will be called when server welcome message and extended config arrive.
---@param callback fun(message: string, config: ac.INIConfig) @Callback function.
---@return ac.Disposable
function ac.onOnlineWelcome(callback)
  __util.callable(callback)
	return __util.disposable(ffi.C.lj_onOnlineWelcome_inner(__util.setCallback(function (message, config)
    callback(message, ac.INIConfig(ac.INIFormat.Extended, config))
  end)))
end
