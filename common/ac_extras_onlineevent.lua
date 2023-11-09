__source 'lua/api_extras_connectonline.cpp'

require('./ac_struct_item')

local _created = {}
local _fficdef = ffi.cdef

-- function __script.connectionOnlineCallback(key, carIndex)
--   local car = ac.getCar(carIndex)
--   local registered = _created[tonumber(key)]
--   if registered == nil then
--     ac.error(string.format('Unexpected Lua online event: key=%s', key))
--     return
--   end
--   for i = 1, #registered.callbacks do
--     __util.cbCall(registered.callbacks[i], car, registered.readProxy)
--   end
-- end

---Creates a new type of online event to exchange between scripts running on different clients in an online
---race. Example:
---```
---local chatMessageEvent = ac.OnlineEvent({
---  -- message structure layout:
---  message = ac.StructItem.string(50),
---  mood = ac.StructItem.float(),
---}, function (sender, data)
---  -- got a message from other client (or ourselves; in such case `sender.index` would be 0):
---  ac.debug('Got message: from', sender and sender.index or -1)
---  ac.debug('Got message: text', data.message)
---  ac.debug('Got message: mood', data.mood)
---end)
---
----- sending a new message:
---chatMessageEvent{ message = 'hello world', mood = 5 }
---```
---
---Note: to exchange messages between two scripts, both of them chould use `ac.OnlineEvent()` and pass exactly the same layouts. Also, consider using more
---specific names to avoid possible unwanted collisions. For example, instead of using `value = ac.StructItem.int()` which might be
---used somewhere else, use `mySpecificValue = ac.StructItem.int()`. Or, simply add `ac.StructItem.key('myUniqueKey')`.
---
---For safety reasons, car scripts can only exchange messages with other car scripts, and track scripts can only exchange messages with other track scripts. 
---Your own messages will arrive to you as well unless you were to use `target` with ID different from your session ID, you might need to filter out those
---messages. 
---
---If the server is not a custom AC Server (use `ac.getSim().directMessagingAvailable` to check), but the original implementation, following restrictions apply:
---- Each message should be smaller than 175 bytes.
---- At least 200 ms should pass between sending messages. 
---- UDP messages are not available (those require `ac.getSim().directUDPMessagingAvailable` flag). 
---- Don’t use this system to exchange data too often: it uses chat messages to transfer data, so it’s far from optimal.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Alternatively, you can pass a string for the body of the structure here, but be careful with it.
---@param callback fun(sender: ac.StateCar|nil, message: T) @Callback that will be called when a new message of this type is received. Note: it would be called even if message was sent from this script. Use `sender` to check message origin: if it’s `nil`, message has come from the server, if its `.index` is 0, message has come from this client (and possibly this script).
---@param namespace nil|ac.SharedNamespace @Optional namespace stopping scripts of certain types to access data of scripts with different types. For more details check `ac.SharedNamespace` documentation.
---@param udp boolean|{range: number} @Pass `true` to use UDP messages (available for Lua apps and online scripts only). Use `ac.getSim().directUDPMessagingAvailable` to check if you could use `udp` flag before hand. Note: enabling this option means `repeatForNewConnections` parameter will be ignored. Alternatively, pass a table with advanced UDP settings.
---@return fun(message: T?, repeatForNewConnections: nil|boolean, target: nil|integer): boolean @Function for sending new messages of newly created type. Pass a new table to set fields of a new message. If any field is missing, it would be set to the default zero state. Set `repeatForNewConnections` to `true` if this message should be re-sent later for newly connected cars (good if you’re announcing a change of state, like, for example, a custom car paint color). If after setting it to `true` a function would be called again without `repeatForNewConnections` set to `true`, further re-sending will be deactivated. Function returns `true` if message has been sent successfully, or `false` otherwise (for example, if rate limits were exceeded). Note: `repeatForNewConnections` is ignored for `udp` events. Parameter `target` can be used to specify session ID of a car that needs to receive the message. Use negative number to send message to everybody, or `255` to send it to the server (expecting some plugin to pick the message up). CSP builds before 2506 ignore messages with configured `target` parameter.
---@return fun(): T @This function returns the actual data pointer to which you could write arguments directly without having to create a new table, might be useful if you need to send a lot of messages (be careful though, there are all sorts of limits with the original AC server implementation). Call this function once, save the returned reference, and each time you need to send a new message fill it with required data and call the first function with `nil` as `message`.
function ac.OnlineEvent(layout, callback, namespace, udp)
  local layoutStr = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end

  if not __allowIO__ and namespace == ac.SharedNamespace.Global then error('Script of this type can’t use global namespace', 2) end

  local key, baseFlags
  if type(namespace) == 'table' and type(namespace.__key) == 'number' then
    -- Some Lua things (with apps or online API) can send messages with a custom type
    key = namespace.__key
    baseFlags = 4
    namespace = nil
  else
    key = ffi.C.lj_connectonline_key(layoutStr, type(namespace) == 'string' and namespace or nil)
    baseFlags = 0
  end

  local created = _created[tonumber(key)]
  if created ~= nil then
    table.insert(created.callbacks, callback)
    return created.sendFn, created.accessFn
  end

  local name = '__coo_'..tostring(key)
  _fficdef(ac.StructItem.__cdef(name, layoutStr, true))
  local size = ffi.sizeof(name)
  if not size or size > 175 and not ac.getSim().directMessagingAvailable then
    error(string.format('Structure is too large (%d bytes; limit is 175 bytes)', size), 2)
  end

  if udp == true or type(udp) == 'table' then
    baseFlags = baseFlags + 2
    if not ac.getSim().directUDPMessagingAvailable then
      error('UDP messages are not available with this server', 2)
    end
  end

  local writeObj, writeProxy, accessedDirectly
  local accessFn = function ()
    if not writeProxy then
      writeObj = ffi.new(name)
      writeProxy = ac.StructItem.__proxy(layout, writeObj)
    elseif not accessedDirectly then
      ffi.fill(writeObj, size)
    end
    return writeProxy
  end

  local readObj = ffi.new(name)
  created = {
    sendFn = function (args, repeatForNewConnections, target)
      local p = accessFn()
      if args and args ~= p then
        for k, v in pairs(args) do
          p[k] = v
        end
      end
      return ffi.C.lj_connectonline_send(key, writeObj, size, baseFlags + (repeatForNewConnections == true and 1 or 0),
        tonumber(target) or -1, type(udp) == 'table' and tonumber(udp.range) or 0)
    end,
    accessFn = function ()
      accessedDirectly = true
      return accessFn()
    end,
    readProxy = ac.StructItem.__proxy(layout, readObj),
    callbacks = { callback },
  }

  _created[tonumber(key)] = created
  ffi.C.lj_connectonline_listen(key, baseFlags, readObj, size, __util.setCallback(function (carIndex)
    local car = ac.getCar(carIndex)
    for i = 1, #created.callbacks do
      __util.cbCall(created.callbacks[i], car, created.readProxy)
    end
  end))
  return created.sendFn, created.accessFn
end
