__source 'lua/api_web.cpp'
__namespace 'web'

local function encodeHeaders(headers)
  if headers == nil then return nil end
  local ret = nil
  for key, value in pairs(headers) do
    ret = (ret ~= nil and ret..'\n' or '')..key..'='..value
  end
  return ret
end

local function parseHeaders(headers)
  local ret = {}
  for k, v in string.gmatch(headers, "([%a%d%-]+): ([%g ]+)\r\n") do
    ret[k:lower()] = v
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
  if ffi.C.lj_http_request__web(__util.str(method), __util.str(url), encodeHeaders(headers), 
      data ~= nil and tostring(data) or nil, requestCallback(callback)) == false then
    error('Invalid arguments', 2)
  end
end

---Web module.
web = {}

---Sends a GET HTTP request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param url string @URL.
---@param headers table<string, string>? @Optional headers.
---@param callback fun(err: string, response: WebResponse)
---@overload fun(url: string, callback: fun(err: string, response: WebResponse))
function web.get(url, headers, callback)
  if type(headers) == 'function' then headers, callback = nil, headers end -- get(url, callback)
  request('GET', url, headers, nil, callback)
end

---Sends a POST HTTP request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param url string @URL.
---@param headers table<string, string>? @Optional headers.
---@param data string? @Optional data.
---@param callback fun(err: string, response: WebResponse)
---@overload fun(url: string, data: string, callback: fun(err: string, response: WebResponse))
---@overload fun(url: string, callback: fun(err: string, response: WebResponse))
function web.post(url, headers, data, callback)
  if type(headers) == 'function' then headers, data, callback = nil, nil, headers -- post(url, callback)
  elseif type(headers) == 'string' then headers, data, callback = nil, headers, data -- post(url, data, callback)
  elseif type(data) == 'function' then data, callback = nil, data end -- post(url, headers, callback)
  request('POST', url, headers, data, callback)
end

---Sends a custom HTTP request. Note: you can only have two requests running at once, mostly to make sure
---a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
---to one of my API tokens for some time, accidentally sending a request each frame).
---@param method "'GET'"|"'POST'"|"'PUT'"|"'HEAD'"|"'DELETE'"|"'PATCH'"|"'OPTIONS'" @HTTP method.
---@param url string @URL.
---@param headers table<string, string>? @Optional headers.
---@param data string? @Optional data.
---@param callback fun(err: string, response: WebResponse)
---@overload fun(method: string, url: string, data: string, callback: fun(err: string, response: WebResponse))
---@overload fun(method: string, url: string, callback: fun(err: string, response: WebResponse))
function web.request(method, url, headers, data, callback)
  if type(headers) == 'function' then headers, data, callback = nil, nil, headers -- post(url, callback)
  elseif type(headers) == 'string' then headers, data, callback = nil, headers, data -- post(url, data, callback)
  elseif type(data) == 'function' then data, callback = nil, data end -- post(url, headers, callback)
  request(method, url, headers, data, callback)
end
