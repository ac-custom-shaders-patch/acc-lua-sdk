__source 'lua/api_extras_connectonline.cpp'

require('./ac_struct_item')

local _created = {}
local _fficdef = ffi.cdef

function __script.connectionOnlineCallback(key, carIndex)
  local car = ac.getCar(carIndex)
  local registered = _created[tonumber(key)]
  if registered == nil then
    ac.error(string.format('Unexpected Lua online event: key=%s', key))
    return
  end
  local data = ac.StructItem.__proxy(registered.layout, ffi.cast(registered.name..'*', ffi.C.lj_connectonline_get(key)))
  table.forEach(registered.callbacks, function (c) __util.cbCall(c, car, data) end)
end

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
---
---Each message should be smaller than 175 bytes. At least 200 ms should pass between sending messages. Don’t use this system to exchange data too often: at
---current stage, it uses chat messages to transfer data, so it’s far from optimal.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Alternatively, you can pass a string for the body of the structure here, but be careful with it.
---@param callback fun(sender: ac.StateCar|nil, message: T) @Callback that will be called when a new message of this type is received. Note: it would be called even if message was sent from this script. Use `sender` to check message origin: if it’s `nil`, message has come from the server, if its `.index` is 0, message has come from this client (and possibly this script).
---@return fun(message: T, repeatForNewConnections: boolean) @Function for sending new messages of newly created type. Pass a new table to set fields of a new message. If any field is missing, it would be set to default zero state. Set `repeatForNewConnections` to `true` if this message should be re-sent later for newly connected cars (good if you’re announcing a change of state, like, for example, a custom car paint color). If after setting it to `true` a function would be called again without `repeatForNewConnections` set to `true`, further re-sending will be deactivated.
function ac.OnlineEvent(layout, callback)
  local layoutStr = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end
  if layoutStr:match('%(') then error('Invalid layout', 2) end

  local key = ffi.C.lj_connectonline_key(layoutStr)
  local name = '__coo_'..tostring(key)

  local created = _created[tonumber(key)]
  if created ~= nil then
    table.insert(created.callbacks, callback)
    return created.sendFn
  end

  _fficdef(ac.StructItem.__cdef(name, layoutStr, true))
  local size = ffi.sizeof(name)
  if size > 175 then
    error(string.format('Structure is too large (%d bytes; limit is 175 bytes)', size), 2)
  end
  created = {
    sendFn = function (args, repeatForNewConnections)
      local instance = ffi.new(name)
      if args then 
        local p = ac.StructItem.__proxy(layout, instance)
        table.forEach(args, function (value, key, p) p[key] = value end, p) 
      end
      ffi.C.lj_connectonline_send(key, instance, size, repeatForNewConnections == true)
    end,
    callbacks = { callback },
    layout = layout,
    name = name
  }
  _created[tonumber(key)] = created
  ffi.C.lj_connectonline_listen(key)
  return created.sendFn
end
