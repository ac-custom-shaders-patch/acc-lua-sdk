local _lastId = 0
local _timeouts = {}
local _timeoutsN = 0
local _tremove = table.remove

---Runs callback after certain time. Returns cancellation ID.
---Note: all callbacks will be ran before `update()` call,
---and they would only ran when script runs. So if your script is executed each frame and AC runs at 60 FPS, smallest interval
---would be 0.016 s, and anything lower that you’d set would still act like 0.016 s. Also, intervals would only be called once
---per frame.
---@param callback fun()
---@param delay number? @Delay time in seconds. Default value: 0.
---@param uniqueKey any? @Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.
---@return integer
function setTimeout(callback, delay, uniqueKey)
  if not _sim then
    _sim = ac.getSim()
  end
  if uniqueKey ~= nil then
    for i = 1, _timeoutsN do
      if _timeouts[i].key == uniqueKey then return _timeouts[i].id end
    end
  end

  local nextTime = _sim.gameTime + (delay or 0)
  local id = _lastId
  _lastId = _lastId + 1
  local n = _timeoutsN + 1
  _timeoutsN = n
  _timeouts[n] = { id = id, callback = callback, nextTime = nextTime, key = uniqueKey }
  ffi.C.lj_set_timer_next(nextTime, false)
  return id
end

---Repeteadly runs callback after certain time. Returns cancellation ID.
---Note: all callbacks will be ran before `update()` call,
---and they would only ran when script runs. So if your script is executed each frame and AC runs at 60 FPS, smallest interval
---would be 0.016 s, and anything lower that you’d set would still act like 0.016 s. Also, intervals would only be called once
---per frame.
---@param callback fun()
---@param period number? @Period time in seconds. Default value: 0.
---@param uniqueKey any? @Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.
---@return integer
function setInterval(callback, period, uniqueKey)
  if not _sim then
    _sim = ac.getSim()
  end
  if uniqueKey ~= nil then
    for i = 1, _timeoutsN do
      if _timeouts[i].key == uniqueKey then return _timeouts[i].id end
    end
  end

  if not period then period = 0 end
  local nextTime = _sim.gameTime + period
  local id = _lastId
  _lastId = _lastId + 1
  local n = _timeoutsN + 1
  _timeoutsN = n
  _timeouts[n] = { id = id, callback = callback, nextTime = nextTime, period = period, key = uniqueKey }
  ffi.C.lj_set_timer_next(nextTime, false)
  return id
end

local _clearPostponed, _clearStorage = nil, nil

---Stops timeout.
---@param cancellationID integer @Value earlier retuned by `setTimeout()`. If a non-numerical value is passed (like a `nil`), call is ignored and returns `false`.
---@return boolean @True if timeout with such ID has been found and stopped.
function clearTimeout(cancellationID)
  if type(cancellationID) ~= 'number' then return false end
  if _clearPostponed then
    local n = _timeoutsN
    for i = 1, n do
      local t = _timeouts[i]
      if t.id == cancellationID then
        table.insert(_clearPostponed, cancellationID)
        return true
      end
    end
    return false
  else
    local n = _timeoutsN
    local m = math.huge
    local r = false
    for i = 1, n do
      local t = _timeouts[i]
      if t.id == cancellationID then
        _tremove(_timeouts, i)
        _timeoutsN = n - 1
        r = true
      elseif t.nextTime < m then
        m = t.nextTime
      end
    end
    ffi.C.lj_set_timer_next(m, true)
    return r
  end
end

---Stops interval.
---@param cancellationID integer @Value earlier retuned by `setInterval()`.
---@return boolean @True if interval with such ID has been found and stopped.
function clearInterval(cancellationID)
  return clearTimeout(cancellationID)
end

function __util.timersLeft()
  return _timeoutsN
end

function __script.updateInner()
  if not _sim then
    return math.huge
  end
  local nextDelay = math.huge
  local now = tonumber(_sim.gameTime)
  local i = 1
  if not _clearStorage then
    _clearStorage = {}
  end
  _clearPostponed = _clearStorage
  while i <= _timeoutsN do
    local t = _timeouts[i]
    local n = t.nextTime
    if n < now then
      if not t.period then
        _tremove(_timeouts, i)
        _timeoutsN = _timeoutsN - 1
        t.callback()
        goto next
      end

      t.callback()
      n = n + t.period
      t.nextTime = n
    end
    if n < nextDelay then
      nextDelay = n
    end
    i = i + 1
    ::next::
  end
  _clearPostponed = nil

  if #_clearStorage > 0 then
    nextDelay = math.huge
    for j = _timeoutsN, 1, -1 do
      local t = _timeouts[j]
      if table.contains(_clearStorage, t.id) then
        _tremove(_timeouts, j)
        _timeoutsN = _timeoutsN - 1
      elseif t.nextTime < nextDelay then
        nextDelay = t.nextTime
      end
    end
    table.clear(_clearStorage)
  end

  return nextDelay
end
