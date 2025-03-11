__definitions()

local __escapeMapInv = { [34] = '"', [39] = '\'', [47] = '/', [92] = '\\', [98] = '\8', [102] = '\12', [110] = '\n', [114] = '\13', [116] = '\9' }

local function __nextNonWhitespace(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if b ~= 9 and b ~= 10 and b ~= 13 and b ~= 32 then return j end
  end
end

local function __nextDelimiter(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if not b or b == 9 or b == 10 or b == 13 or b == 32 or b == 44 or b == 93 or b == 125 then return j end
  end
end

local function __skip(str, i, commas)
  local o = string.byte(str, i)
  while o == 47 or commas and o == 44 do
    if o == 44 then
      i = __nextNonWhitespace(str, i + 1)
    elseif string.byte(str, i + 1) == 47 then
      for j = i + 2, #str do
        if string.byte(str, j) == 10 or string.byte(str, j) == 13 then
          i = __nextNonWhitespace(str, j + 1)
          break
        end
      end
    elseif string.byte(str, i + 1) == 42 then
      for j = i + 2, #str do
        if string.byte(str, j) == 42 and string.byte(str, j + 1) == 47 then
          i = __nextNonWhitespace(str, j + 2)
          break
        end
      end
    else
      return #str + 1, nil
    end
    o = string.byte(str, i)
  end
  return i, o
end


local function __endOfKey(str, i)
  for j = i, math.max(i, #str + 1) do
    local b = string.byte(str, j)
    if not b or b == 58 then return str:sub(i - 1, j - 1):trim(), j + 1 end
    if b == 47 and (string.byte(str, j + 1) == 47 or string.byte(str, j + 1) == 42) then
      local k = str:sub(i - 1, j - 1):trim()
      return k, __skip(str, j) + 1
    end
  end
end

local function __jsonParse(str, i)
  local o
  i, o = __skip(str, i)
  if o == 34 or o == 39 then
    local res, j, k = '', i + 1, i + 1
    while true do
      local x = string.byte(str, j)
      if not x or x == o then
        return res..str:sub(k, j - 1), j + 1
      elseif x == 92 then
        res, j = res..str:sub(k, j - 1), j + 1
        local c = string.byte(str, j)
        if c == 117 then
          local hex = str:match('^[dD][89aAbB]%x%x\\u%x%x%x%x', j + 1) or str:match('^%x%x%x%x', j + 1) or ''
          local n1, n2 = tonumber(hex:sub(1, 4), 16), tonumber(hex:sub(7, 10), 16)
          res, j = res..(n2 and (string.codePointToUTF8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000))
            or n1 and string.codePointToUTF8(n1) or ''), j + #hex
        else
          res = res..(__escapeMapInv[c] or '')
        end
        k = j + 1
      end
      j = j + 1
    end
  elseif o == 116 then
    if str:sub(i, i + 3) == 'true' then return true, i + 4 end
    return nil, __nextDelimiter(str, i)
  elseif o == 102 then
    if str:sub(i, i + 4) == 'false' then return false, i + 5 end
    return nil, __nextDelimiter(str, i)
  elseif o == 110 then
    if str:sub(i, i + 3) == 'null' then return nil, i + 4 end
    return nil, __nextDelimiter(str, i)
  elseif o >= 48 and o <= 57 or o == 45 then
    local x = __nextDelimiter(str, i)
    return tonumber(str:sub(i, x - 1)), x
  elseif o == 91 or o == 123 then
    local res, key = {}, nil
    i = i + 1
    -- print(string.sub(str, i))
    while i < #str do
      i = __nextNonWhitespace(str, i)
      i = __skip(str, i, true)
      if string.byte(str, i) == 93 or string.byte(str, i) == 125 then --[[ ], } ]]
        -- print('END: %s' % string.sub(str, i))
        return res, i + 1
      end
      if o == 91 then --[[ [ ]]
        res[#res + 1], i = __jsonParse(str, i)
      elseif o == 123 then --[[ { ]]
        if string.byte(str, i) == 34 or string.byte(str, i) == 39 then --[[ ", ' ]]
          key, i = __jsonParse(str, i)
          i = __nextNonWhitespace(str, i)
          i = __skip(str, i)
          -- print(key)
          -- print(string.byte(str, i))
          if string.byte(str, i) == 58 --[[ : ]] then i = i + 1 end
        else
          key, i = __endOfKey(str, i + 1)
        end
        res[tostring(key)], i = __jsonParse(str, __nextNonWhitespace(str, i))
      end
    end
    -- print('ERR:'.. string.sub(str, i))
    return res, #str + 1
  else
    return nil, #str + 1
  end
end

return function(str)
  if str == nil then return nil end
  str = tostring(str)
  local s, r = pcall(__jsonParse, str, __nextNonWhitespace(str, 1))
  if s then return r end
  return nil
end