ac = {}
__util = {}
ffi = require('ffi')
io = require('io')
__script = {}
package.path = package.path .. ';' .. './common/?.lua'

--[[?
out(inc('common/class.lua'))
out(inc('common/table.lua'))
out(inc('common/function.lua'))
out(inc('common/ac_primitive.lua'))
out(inc('common/internal.lua'))
out(inc('common/string.lua'))
out(inc('common/table.lua'))
out(inc('common/stringify.lua'))
out(inc('common/json.lua'))
out(inc('common/const.lua'))
?]]  -- we need macros working

function print(v)
  io.stderr:write(v)
  io.stderr:write('\n')
  io.stderr:flush()
end

local successfulTests = 0
shutdownproxy = newproxy(true)
getmetatable(shutdownproxy).__gc = function() 
  io.write(string.format('\t%d tests passed\n', successfulTests))
end

-- Because proper version is in C++, here are some simple versions
function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function string.trim(s)
  return s:match"^%s*(.*)":match"(.-)%s*$"
end

function string.codePointToUTF8(n)
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
  if n <= 0x7f then
    return string.char(n)
  elseif n <= 0x7ff then
    return string.char(math.floor(n / 64) + 192, n % 64 + 128)
  elseif n <= 0xffff then
    return string.char(math.floor(n / 4096) + 224, math.floor(n % 4096 / 64) + 128, n % 64 + 128)
  elseif n <= 0x10ffff then
    return string.char(math.floor(n / 262144) + 240, math.floor(n % 262144 / 4096) + 128,
      math.floor(n % 4096 / 64) + 128, n % 64 + 128)
  end
  return ''
end

function io.load(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local function findCallerLine(mask)
  local caller = debug.traceback():split('\n')[4]:trim()
  caller = caller:gsub(': in main.*', '')
  local file = caller:split(':')
  if #file == 2 and mask ~= nil then
    local data = io.load(file[1]):split('\n')
    local line = data[tonumber(file[2])]
    if line ~= nil then
      local m = line:gmatch(mask)()
      return caller, m
    end
  end
  return caller
end

local _tnkeys = require('table.nkeys')
local _tisarray = require('table.isarray')

function sameAs(a, b)
  if a == b then return true end
  if type(a) ~= type(b) then return false end
  if type(a) == 'table' then
    if _tisarray(a) then
      if not _tisarray(b) or #a ~= #b then return false end
      for i = 1, #a do
        if not sameAs(a[i], b[i]) then return false end
      end
      return true
    else
      if _tisarray(b) or _tnkeys(a) ~= _tnkeys(b) then return false end
      for k, v in pairs(a) do
        if not sameAs(v, b[k]) then return false end
      end
      return true
    end
  end
  return false
end

function serialize(a)
  return stringify(a)
  -- if type(a) == 'table' then return '{' .. table.join(a, ', ', serialize) .. '}' end
  -- return tostring(a)
end

function expect(a, b)
  if not sameAs(a, b) then
    local caller, value = findCallerLine('expect%((.-),')
    if value == nil then
      io.stderr:write(string.format('\t%s: expected %s, got %s\n', caller, serialize(b), serialize(a)))
    else
      io.stderr:write(string.format('\t%s: %s is %s (expected %s)\n', caller, value, serialize(a), serialize(b)))
    end
  else
    successfulTests = successfulTests + 1
    -- print('\tTest passed: '..findCallerLine())
  end
end

function expectClose(a, b, t)
  if math.abs(a - b) > t then
    local caller, value = findCallerLine('expect%((.-),')
    if value == nil then
      io.stderr:write(string.format('\t%s: expected %s, got %s\n', caller, serialize(b), serialize(a)))
    else
      io.stderr:write(string.format('\t%s: %s is %s (expected %s)\n', caller, value, serialize(a), serialize(b)))
    end
  else
    successfulTests = successfulTests + 1
    -- print('\tTest passed: '..findCallerLine())
  end
end

function expectOneOf(a, b)
  if not table.some(b, function (i) return sameAs(a, i) end) then
    local caller, value = findCallerLine('expect%((.-),')
    if value == nil then
      io.stderr:write(string.format('\t%s: expected %s, got %s\n', caller, serialize(b), serialize(a)))
    else
      io.stderr:write(string.format('\t%s: %s is %s (expected %s)\n', caller, value, serialize(a), serialize(b)))
    end
  else
    successfulTests = successfulTests + 1
    -- print('\tTest passed: '..findCallerLine())
  end
end

function expectError(fn, error)
  local success, err = pcall(fn)
  if success or err:match(error) == nil then
    local caller = findCallerLine()
    if success then
      io.stderr:write(string.format('\t%s: expected an error “%s”, didn’t happen\n', caller, error))
    else
      io.stderr:write(string.format('\t%s: expected an error “%s”, but got “%s”\n', caller, error, err))
    end
  else
    successfulTests = successfulTests + 1
    -- print('\tTest passed: '..findCallerLine())
  end
end

local function tablePrint (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, tablePrint (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end
function niceString( tbl )
  if  "nil"       == type( tbl ) then
      return tostring(nil)
  elseif  "table" == type( tbl ) then
      return tablePrint(tbl)
  elseif  "string" == type( tbl ) then
      return tbl
  else
      return tostring(tbl)
  end
end