__source 'lua/api_extras_connectonline.cpp'
require './common/internal_import'

local _created = {}

__definitions()

return function (layout, callback, namespace, udp, params)
  local layoutStr = __util.__si_build(layout)
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

  local s_name = __util.__si_ffi(layoutStr, true)
  local size = ffi.sizeof(s_name)
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
      writeObj = ffi.new(s_name)
      writeProxy = __util.__si_proxy(layout, writeObj)
    elseif not accessedDirectly then
      ffi.fill(writeObj, size)
    end
    return writeProxy
  end

  local readObj = ffi.new(s_name)
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
    readProxy = __util.__si_proxy(layout, readObj),
    callbacks = { callback },
  }

  if type(params) == 'table' and not not params.processPostponed then
    baseFlags = baseFlags + 8
  end

  _created[tonumber(key)] = created
  ffi.C.lj_connectonline_listen(key, baseFlags, readObj, size, __util.setCallback(function (carIndex)
    local car = ac.getCar(carIndex)
    for i = 1, #created.callbacks do
      __util.cbCall(created.callbacks[i], car, created.readProxy)
    end
  end))

  return created.sendFn, created.accessFn
end
