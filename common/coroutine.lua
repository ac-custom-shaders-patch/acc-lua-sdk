local ccreate = coroutine.create
local cresume = coroutine.resume
local dtraceback = debug.traceback
local threads = setmetatable({}, {__mode = 'kv'})

---Creates a new coroutine, with body `f`. `f` must be a function. Returns this new coroutine, an object with type `thread`.
---@param f async fun(...): ...
---@param flags nil|'e'|'s'|'es' @Flags: use `e` to raise errors from coroutine, `s` to start the coroutine immediately, or `es` for both. 
---@return thread
function coroutine.create(f, flags)
  local co = ccreate(f)
  if flags then
    if string.find(flags, 'e', nil, true) then threads[co] = true end
    if string.find(flags, 's', nil, true) then coroutine.resume(co) end
  end
  return co
end
 
local function cerrhandler(co, ok, ...)
  if not ok then
    error(dtraceback(co, select(1, ...)), math.huge)
  end
  return ...
end

function coroutine.resume(co, ...)
  if threads[co] then
    return cerrhandler(co, cresume(co, ...))
  end
  return cresume(co, ...)
end

---Sleep for some time.
---@async
---@param time number @Time to sleep in seconds.
function coroutine.sleep(time)
  local co = coroutine.running()
  setTimeout(function () coroutine.resume(co) end, time)
  coroutine.yield(co)
end