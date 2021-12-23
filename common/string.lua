---Splits string using separator.
---@param self string @String to split.
---@param separator string @Separator.
---@param limit integer? @Limit for pieces of string. Once reached, remaining string is put as a list piece.
---@return string[]
function string.split(self, separator, limit)
  local t = {}
  local fpat = '(.-)' .. separator
  local last_end = 1
  local s, e, cap = self:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= '' then
      table.insert(t, cap)
    end
    last_end = e+1
    s, e, cap = self:find(fpat, last_end)
    if limit ~= nil and limit <= #t then
      break
    end
  end
  if last_end <= #self then
    cap = self:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

---Trims string from whitespaces at beginning and end.
---@param self string
---@return string
function string.trim(self)
  return self:match'^%s*(.*%S)' or ''
end
