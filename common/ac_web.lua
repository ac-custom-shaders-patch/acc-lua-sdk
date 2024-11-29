__source 'lua/api_web.cpp'
__namespace 'web'

local function encodeHeaders(headers)
  if headers == nil then return nil end
  local ret = nil
  for key, value in pairs(headers) do
    ret = (ret ~= nil and ret..'\n' or '')..key..'='..(value ~= nil and (type(value) == 'boolean' and (value and '1' or '0') or tostring(value)) or '')
  end
  return ret
end

local function parseHeaders(headers)
  local ret = {}
  if type(headers) == 'string' then
    for k, v in string.gmatch(headers, "([%a%d%-]+): ([%g ]+)\r\n") do
      ret[k:lower()] = v
    end
  end
  return ret
end

local function requestCallback(callback)
  if callback == nil then return 0 end
  return __util.expectReply(function (err, status, headers, response)
    callback(err, { status = status, headers = parseHeaders(headers), body = response })
  end)
end

local function request(method, url, headers, data, callback)
  if url == nil then error('URL is required', 2) end

  local ret
  if type(data) == 'table' then
    if url == 'http://not-an-url' and data.filename == 'b:/nonexistent' then
      setTimeout(callback, 0)
      return
    end
  
    ret = ffi.C.lj_http_request_file__web(__util.str(method), __util.str(url), encodeHeaders(headers), data.filename, requestCallback(callback))
  else
    ret = ffi.C.lj_http_request__web(__util.str(method), __util.str(url), encodeHeaders(headers), __util.blob(data), requestCallback(callback))
  end

  if ret == false then
    setTimeout(function ()
      callback('Invalid arguments', nil)
    end, 0)
  end
end

---Web module.
web = {}

---Configures timeouts in milliseconds for the following web requests. If you’re sure in your server, consider lowering timeouts so that
---in a case of a missing internet connection it wouldn’t take forever to determine the issue. Parameters will be passed to `WinHttpSetTimeouts()`
---function (https://learn.microsoft.com/en-us/windows/win32/api/winhttp/nf-winhttp-winhttpsettimeouts).
---@param resolve integer? @Time in milliseconds for DNS resolve, 0 to disable timeout. Default value: 4000 ms.
---@param connect integer? @Time in milliseconds for establishing connection. Default value: 10000 ms.
---@param send integer? @Time in milliseconds for sending data. Default value: 30000 ms.
---@param receive integer? @Time in milliseconds for receiving data. Default value: 30000 ms.
function web.timeouts(resolve, connect, send, receive)
  __util.native('web.timeouts', tonumber(resolve), tonumber(connect), tonumber(send), tonumber(receive))
end

---Sends a GET HTTP or HTTPS request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param url string @URL.
---@param headers table<string, string|number|boolean>? @Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).
---@param callback fun(err: string, response: WebResponse)
---@overload fun(url: string, callback: fun(err: string, response: WebResponse))
function web.get(url, headers, callback)
  if type(headers) == 'function' then headers, callback = nil, headers end -- get(url, callback)
  request('GET', url, headers, nil, callback)
end

---Sends a POST HTTP or HTTPS request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param url string @URL.
---@param headers table<string, string|number|boolean>? @Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).
---@param data WebPayload? @Optional data.
---@param callback fun(err: string, response: WebResponse)
---@overload fun(url: string, data: string, callback: fun(err: string, response: WebResponse))
---@overload fun(url: string, callback: fun(err: string, response: WebResponse))
function web.post(url, headers, data, callback)
  if type(headers) == 'function' then headers, data, callback = nil, nil, headers -- post(url, callback)
  elseif type(headers) == 'string' then headers, data, callback = nil, headers, data -- post(url, data, callback)
  elseif type(data) == 'function' then data, callback = nil, data end -- post(url, headers, callback)
  request('POST', url, headers, data, callback)
end

---Sends a custom HTTP or HTTPS request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param method "'GET'"|"'POST'"|"'PUT'"|"'HEAD'"|"'DELETE'"|"'PATCH'"|"'OPTIONS'" @HTTP method.
---@param url string @URL.
---@param headers table<string, string|number|boolean>? @Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).
---@param data WebPayload? @Optional data.
---@param callback fun(err: string, response: WebResponse)
---@overload fun(method: string, url: string, data: string, callback: fun(err: string, response: WebResponse))
---@overload fun(method: string, url: string, callback: fun(err: string, response: WebResponse))
function web.request(method, url, headers, data, callback)
  if type(headers) == 'function' then headers, data, callback = nil, nil, headers -- post(url, callback)
  elseif type(headers) == 'string' then headers, data, callback = nil, headers, data -- post(url, data, callback)
  elseif type(data) == 'function' then data, callback = nil, data end -- post(url, headers, callback)
  request(method, url, headers, data, callback)
end

---@alias web.SocketParams {onError: nil|fun(err: string), onClose: nil|fun(reason: string?), encoding: nil|'binary'|'utf8'|'json'|'lson', reconnect: boolean?} ---Use property `reconnect` to automatically try and restore connection a few seconds after it got lost. With it, `onError` might be called multiple times, but `onClose` is only called once connection is closed by calling `web.Socket.close()`.
---@alias web.Socket {close: fun()}|fun(data: binary)

---Open a WebSocket connection.
---@param url string @URL.
---@param headers table<string, string|number|boolean>? @Optional headers.
---@param callback nil|fun(data: binary)
---@param params web.SocketParams?
---@return web.Socket
---@overload fun(url: string, callback: fun(data: binary), params: web.SocketParams): web.Socket
function web.socket(url, headers, callback, params)
  if type(headers) == 'function' then
    headers, callback, params = nil, headers, callback
  end
  local encodedParams = nil
  local dataEncode = nil
  local onError = 0
  local onClose = 0
  if type(params) == 'table' then
    encodedParams = {reconnect = not not params.reconnect}
    local dataDecode
    if params.encoding == 'json' then
      dataEncode, dataDecode = JSON.stringify, JSON.parse
    elseif params.encoding == 'lson' then
      dataEncode, dataDecode = function (data) return stringify(data, true, 40) end, stringify.tryParse
    else
      encodedParams.binary_mode = params.encoding == 'binary'
    end
    if dataDecode and callback then
      local callbackBak = callback
      callback = function (data)
        callbackBak(dataDecode(data))
      end
    end
    if params.onError then
      onError = __util.setCallback(params.onError) 
    end
    if params.onClose then
      onClose = __util.setCallback(params.onClose)
    end
  end
  local socket = ffi.C.lj_http_websocket__web(__util.str(url), encodeHeaders(headers), __util.setCallback(callback), onError, onClose, encodedParams and __util.json(encodedParams))
  return setmetatable({
    close = function ()
      ffi.C.lj_http_websocket_send__web(socket, nil)
    end
  }, {
    __call = dataEncode
      and function (_, data) ffi.C.lj_http_websocket_send__web(socket, __util.blob(dataEncode(data))) end 
      or function (_, data) if data ~= nil and (type(data) ~= 'string' or #data > 0) then ffi.C.lj_http_websocket_send__web(socket, __util.blob(data)) end end
  })
end