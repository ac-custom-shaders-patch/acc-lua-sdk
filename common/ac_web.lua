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
  __util.lazy('lib_web').request('GET', url, headers, nil, callback)
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
  __util.lazy('lib_web').request('POST', url, headers, data, callback)
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
  __util.lazy('lib_web').request(method, url, headers, data, callback)
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
  return __util.lazy('lib_web').socket(url, headers, callback, params)
end