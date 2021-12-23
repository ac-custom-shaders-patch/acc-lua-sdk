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
---@param delay number @Delay time in seconds.
---@param uniqueKey any? @Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.
---@return integer
function setTimeout(callback, delay, uniqueKey)
  if uniqueKey ~= nil then
    for i = 1, _timeoutsN do
      if _timeouts[i].key == uniqueKey then return end
    end
  end

  if delay == nil then delay = 0 end
  local id = _lastId
  _lastId = _lastId + 1
  local n = _timeoutsN + 1
  _timeoutsN = n
  _timeouts[n] = { id = id, callback = callback, delay = delay, period = -1, key = uniqueKey }
  return id
end

---Repeteadly runs callback after certain time. Returns cancellation ID.
---Note: all callbacks will be ran before `update()` call,
---and they would only ran when script runs. So if your script is executed each frame and AC runs at 60 FPS, smallest interval
---would be 0.016 s, and anything lower that you’d set would still act like 0.016 s. Also, intervals would only be called once
---per frame.
---@param callback fun()
---@param period number @Period time in seconds.
---@param uniqueKey any? @Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.
---@return integer
function setInterval(callback, period, uniqueKey)
  if uniqueKey ~= nil then
    for i = 1, _timeoutsN do
      if _timeouts[i].key == uniqueKey then return end
    end
  end

  if period == nil then period = 0 end
  local id = _lastId
  _lastId = _lastId + 1
  local n = _timeoutsN + 1
  _timeoutsN = n
  _timeouts[n] = { id = id, callback = callback, delay = period, period = period, key = uniqueKey }
  return id
end

---Stops timeout.
---@param cancellationID integer @Value earlier retuned by `setTimeout()`.
---@return boolean @True if timeout with such ID has been found and stopped.
function clearTimeout(cancellationID)
  local n = _timeoutsN
  for i = 1, n do
    if _timeouts[i].id == cancellationID then
      _tremove(_timeouts, i)
      _timeoutsN = n - 1
      return true
    end
  end
  return false
end

---Stops interval.
---@param cancellationID integer @Value earlier retuned by `setInterval()`.
---@return boolean @True if interval with such ID has been found and stopped.
function clearInterval(cancellationID)
  return clearTimeout(cancellationID)
end

function __script.updateInner(dt)
  __util.updateInner(dt)
  for i = _timeoutsN, 1, -1 do
    local t = _timeouts[i]
    t.delay = t.delay - dt
    if t.delay < 0 then
      if t.period >= 0 then
        t.delay = t.period
      else
        _tremove(_timeouts, i)
        _timeoutsN = _timeoutsN - 1
      end
      local s, err = pcall(t.callback)
      if not s then
        ac.error('Error in timer callback: '..tostring(err))
      end
    end
  end
end