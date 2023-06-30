require './common/internal_import'

-- automatically generated entries go here:
__definitions()

---Nothing from here will be called for background threads.
---@class ScriptData
---@single-instance
script = {}

do
  local __hasResponse, __response, __error
  worker = setmetatable({}, {
    __index = function (s, key)
      if key == 'input' then return __input end
      if key == 'sleep' then return os.sleep end
      if key == 'result' then return __response end
      if key == 'wait' then
        return function (time)
          time = (time or 60) + os.preciseClock()
          while not __hasResponse do
            os.sleep(0.1)
            if os.preciseClock() > time then
              error('Timeout', 1)
            end
          end
        end
      end
    end,
    __newindex = function (s, key, value)
      if key == 'result' then __response, __hasResponse = value, true end
      if key == '__error' then __error, __hasResponse = value, true end
    end
  })

  function __worker_finalize()
    while __util.awaitingCallback() and not __hasResponse do
      os.sleep(0.1)
    end
    if __error then
      error(__error, 2)
    end
    return __response
  end
end

