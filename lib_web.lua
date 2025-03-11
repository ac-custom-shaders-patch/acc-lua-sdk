__source 'lua/api_web.cpp'
__namespace 'web'
require './common/internal_import'

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

__definitions()

return {
  request = request,
  socket = function(url, headers, callback, params)
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
}