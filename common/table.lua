-- To make things simpler, Lua’s table module is extended here

-- local _tisarray = require('table.isarray')
local _tclear = require('table.clear')
local _tclone = require('table.clone')
local _tnkeys = require('table.nkeys')
local _tnew = require('table.new')
local function isArray(t, N)
  -- return type(t) == 'table' and _tisarray(t)
  -- return type(t) == 'table' and N == _tnkeys(t)  -- alternative implementation. note: table.nkeys iterates over all elements for counting 🙄
  -- return type(t) == 'table' and _tisarray(t) and N == _tnkeys(t)  -- might be faster with earlier check, but let’s play it safe
  if type(t) ~= 'table' then return false end
  local f = next(t)
  if type(f) ~= 'number' or f < 0 or f > N then return f == nil end
  local k = next(t, N > 0 and N or nil)  -- does iterate over things, but seems to be more efficient overall
  return k == nil or type(k) == 'number' and k > 0 and k < N  -- specially for {[1]=1,[2]=2} table (and similar ones), where N==2, but next(2) can return 1
end

local function requireArray(t, N)
  if isArray(t, N) then return end
  error('Array is required', 3)
end

---Checks if table is an array or not. Arrays are tables that only have consequtive numeric keys.
---@param t table|any[]
---@return boolean
function table.isArray(t)
  if type(t) ~= 'table' then return false end
  local N = #t
  return isArray(t, N)
end

---Creates a new table with preallocated space for given amount of elements.
---@param arrayElements integer @How many elements the table will have as a sequence.
---@param mapElements integer @How many other elements the table will have.
---@return table
function table.new(arrayElements, mapElements)
  return _tnew(arrayElements, mapElements)
end

---Cleares table without deallocating space using a fast LuaJIT call. Can work
---with both array and non-array tables.
---@param t table
function table.clear(t)
  _tclear(t)
end

---Returns the total number of elements in a given Lua table (i.e. from both the array and hash parts combined).
---@param t table
function table.nkeys(t)
  return _tnkeys(t)
end

---Clones table using a fast LuaJIT call.
---@param t table
function table.clone(t)
  return _tclone(t)
end

---Removes first item by value, returns true if any item was removed. Can work
---with both array and non-array tables.
---@generic T
---@param t table<any, T>
---@param item T
---@return boolean
function table.removeItem(t, item)
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      if t[i] == item then
        table.remove(t, i)
        return true
      end
    end
  else
    local r = nil
    for key, value in pairs(t) do
      if value == item then
        r = key
      end
    end
    if r ~= nil then
      t[r] = nil
      return true
    end
  end
  return false
end

---Returns an element from table with a given key. If there is no such element, calls callback
---and uses its return value to add a new element and return that. Can work
---with both array and non-array tables.
---@generic T
---@generic TCallbackData
---@param t table<any, T>
---@param key any
---@param callback fun(callbackData: TCallbackData): T
---@param callbackData TCallbackData
---@return T
function table.getOrCreate(t, key, callback, callbackData)
  local r = t[key]
  if r == nil then
    r = callback(callbackData)
    t[key] = r
  end
  return r
end

---Returns true if table contains an item. Can work with both array and non-array tables.
---@generic T
---@param t table<any, T>
---@param item T
---@return boolean
function table.contains(t, item)
  local N = #t
  if isArray(t, N) then
    for key = next(t), N do
      if t[key] == item then
        return true
      end
    end
  else
    for _, value in pairs(t) do
      if value == item then
        return true
      end
    end
  end
  return false
end

---Returns a random item from a table. Optional callback works like a filter. Can work
---with both array and non-array tables. Alternatively, optional callback can provide a number
---for a weight of an item.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param filteringCallback fun(item: T, key: TKey, callbackData: TCallbackData): boolean
---@param filteringCallbackData TCallbackData
---@return T
function table.random(t, filteringCallback, filteringCallbackData)
  local mrandom = math.random
  local N = #t
  local r, k = nil, nil
  if isArray(t, N) then
    if filteringCallback == nil then
      k = mrandom(N)
      r = t[k]
    else
      local nc = 0
      for key = next(t), N do
        local value = t[key]
        local f = filteringCallback(value, key, filteringCallbackData)
        if f then
          local w = type(f) == 'number' and f or 1
          nc = nc + w
          if w / nc >= mrandom() then
            r, k = value, key
          end
        end
      end
    end
  else
    local nc = 0
    for key, value in pairs(t) do
      local f = not filteringCallback and 1 or filteringCallback(value, key, filteringCallbackData)
      if f then
        local w = type(f) == 'number' and f or 1
        nc = nc + w
        if 1 / nc >= mrandom() then
          r, k = value, key
        end
      end
    end
  end
  return r, k
end

---Returns a key of a given element, or nil if there is no such element in a table. Can work
---with both array and non-array tables.
---@generic T
---@generic TKey
---@param t table<TKey, T>
---@param item T
---@return TKey|nil
function table.indexOf(t, item)
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      if t[i] == item then
        return i
      end
    end
  else
    for key, value in pairs(t) do
      if value == item then
        return key
      end
    end
  end
  return nil
end

local _tjsp, _tjsn = {}, 0

---Joins elements of a table to a string, works with both arrays and non-array tables. Optinal
---toStringCallback parameter can be used for a custom item serialization. All parameters but
---`t` (for actual table) are optional and can be skipped.
---
---Note: it wouldn’t work as fast as `table.concat`, but it would call a `tostring()` (or custom
---serializer callback) for each element.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param itemsJoin string @Default value: ','.
---@param keyValueJoin string @Default value: '='.
---@param toStringCallback fun(item: T, key: TKey, callbackData: TCallbackData): string
---@param toStringCallbackData TCallbackData
---@overload fun(t: table, itemsJoin: string, toStringCallback: fun(item: any, key: any, callbackData: any), toStringCallbackData: any)
---@overload fun(t: table, toStringCallback: fun(item: any, key: any, callbackData: any), toStringCallbackData: any)
---@return TKey|nil
function table.join(t, itemsJoin, keyValueJoin, toStringCallback, toStringCallbackData)
  if type(itemsJoin) == 'function' then
    itemsJoin, keyValueJoin, toStringCallback, toStringCallbackData = nil, nil, itemsJoin, keyValueJoin
  end
  if type(keyValueJoin) == 'function' then
    keyValueJoin, toStringCallback, toStringCallbackData = nil, keyValueJoin, toStringCallback
  end
  if itemsJoin == nil then itemsJoin = ',' end

  if toStringCallback == nil and keyValueJoin == nil then keyValueJoin = '=' end
  toStringCallback = toStringCallback or tostring

  local N = #t
  local tjsn = _tjsn
  local p = tjsn > 0 and _tjsp[tjsn] or {}
  if tjsn > 0 then _tjsn = tjsn - 1 end

  local pN = 1
  if isArray(t, N) then
    for key = next(t), N do
      p[pN], pN = toStringCallback(t[key], key, toStringCallbackData), pN + 1
    end
  elseif keyValueJoin then
    keyValueJoin = tostring(keyValueJoin)
    for key, value in pairs(t) do
      if pN ~= 1 then
        p[pN] = itemsJoin
        pN = pN + 1
      end
      p[pN] = tostring(key)
      p[pN + 1] = keyValueJoin
      p[pN + 2] = toStringCallback(value, key, toStringCallbackData)
      pN = pN + 3
    end
    itemsJoin = nil
  else
    for key, value in pairs(t) do
      p[pN], pN = toStringCallback(value, key, toStringCallbackData), pN + 1
    end
  end

  tjsn = _tjsn + 1
  _tjsp[tjsn], _tjsn = p, tjsn
  local r = table.concat(p, itemsJoin)
  _tclear(p)
  return r
end

local _mmax = math.max
local _mfloor = math.floor

local function numberOfSteps(from, to, step)
  return _mmax(0, _mfloor(1 + (to - from) / step))
end

---Slices array, basically acts like slicing thing in Python.
---@generic T
---@param t T[]
---@param from integer @Starting index.
---@param to integer? @Ending index.
---@param step integer? @Step.
---@return T[]
function table.slice(t, from, to, step)
  local N = #t
  requireArray(t, N)
  if from == nil or from == 0 then from = 1 elseif from < 0 then from = N + from end
  if to == nil or to == 0 then to = N elseif to < 0 then to = N + to end
  if step == nil or step == 0 then step = 1 end
  local ret = _tnew(numberOfSteps(from, to, step), 0)
  if step > 0 and to >= from or step < 0 and to <= from then
    local I = 1
    for i = from, to, step do
      ret[I] = t[i]
      I = I + 1
    end
  end
  return ret
end

---Flips table from back to front, requires an array.
---@generic T
---@param t T[]
---@return T[]
function table.reverse(t)
  local N = #t
  local ret = _tnew(N, 0)
  requireArray(t, N)
  for i = N, next(t), -1 do
    ret[N - i + 1] = t[i]
  end
  return ret
end

---Calls callback function for each of table elements, creates a new table containing all the resulting values.
---Can work with both array and non-array tables. For non-array tables, new table is going to be an array unless
---callback function would return a key as a second return value.
---
---If callback returns two values, second would be used as a key to create a table-like table (not an array-like one).
---
---Note: if callback returns `nil`, value will be skipped, so this function can act as a filtering one too.
---@generic T
---@generic TKey
---@generic TCallbackData
---@generic TReturnKey
---@generic TReturnValue
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): TReturnValue, TReturnKey|nil @Mapping callback.
---@param callbackData TCallbackData
---@return table<TReturnKey, TReturnValue>
function table.map(t, callback, callbackData)
  local ret = {}
  local N = #t
  local I = 1
  if isArray(t, N) then
    for key = next(t), N do
      local newValue, newKey = callback(t[key], key, callbackData)
      if newValue ~= nil then
        if newKey ~= nil then
          ret[newKey] = newValue
        else
          ret[I], I = newValue, I + 1
        end
      end
    end
  else
    for key, value in pairs(t) do
      local newValue, newKey = callback(value, key, callbackData)
      if newValue ~= nil then
        if newKey ~= nil then
          ret[newKey] = newValue
        else
          ret[I], I = newValue, I + 1
        end
      end
    end
  end
  return ret
end

---Calls callback function for each of table elements, creates a new table containing all the resulting values.
---Can work with both array and non-array tables. For non-array tables, new table is going to be an array unless
---callback function would return a key as a second return value.
---
---If callback returns two values, second would be used as a key to create a table-like table (not an array-like one).
---
---Note: if callback returns `nil`, value will be skipped, so this function can act as a filtering one too.
---@generic T
---@generic TKey
---@generic TCallbackData
---@generic TData
---@param t table<TKey, T>
---@param startingValue TData
---@param callback fun(data: TData, item: T, index: TKey, callbackData: TCallbackData): TData @Reduction callback.
---@param callbackData TCallbackData
---@return TData
function table.reduce(t, startingValue, callback, callbackData)
  local N = #t
  if isArray(t, N) then
    for key = next(t), N do
      startingValue = callback(startingValue, t[key], key, callbackData)
    end
  else
    for key, value in pairs(t) do
      startingValue = callback(startingValue, value, key, callbackData)
    end
  end
  return startingValue
end

---Creates a new table from all elements for which filtering callback returns true. Can work with both
---array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): any @Filtering callback.
---@param callbackData TCallbackData
---@return table<TKey, T>
function table.filter(t, callback, callbackData)
  local ret = {}
  local N = #t
  if isArray(t, N) then
    local I = 1
    for key = next(t), N do
      local value = t[key]
      if callback(value, key, callbackData) then
        ret[I] = value
        I = I + 1
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key, callbackData) then
        ret[key] = value
      end
    end
  end
  return ret
end

---Returns true if callback returns non-false value for every element of the table. Can work with both
---array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData
---@return boolean
function table.every(t, callback, callbackData)
  local N = #t
  if isArray(t, N) then
    for key = next(t), N do
      local v = callback(t[key], key, callbackData)
      if not v then
        return false
      end
    end
  else
    for key, value in pairs(t) do
      local v = callback(value, key, callbackData)
        if not v then
          return false
        end
    end
  end
  return true
end

---Returns true if callback returns non-false value for at least a single element of the table. Can work
---with both array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData
---@return boolean
function table.some(t, callback, callbackData)
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      if callback(t[i], i, callbackData) then
        return true
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key, callbackData) then
        return true
      end
    end
  end
  return false
end

---Counts number of elements for which callback returns non-false value. Can work
---with both array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData
---@return integer
function table.count(t, callback, callbackData)
  local n, r = #t, 0
  if isArray(t, n) then
    for i = next(t), n do
      if callback(t[i], i, callbackData) then
        r = r + 1
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key, callbackData) then
        r = r + 1
      end
    end
  end
  return r
end

---Calls callback for each element, returns sum of returned values. Can work
---with both array and non-array tables. If callback is missing, sums actual values in table.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData
---@return integer
function table.sum(t, callback, callbackData)
  local n, r = #t, 0
  if isArray(t, n) then
    for i = next(t), n do
      local v = callback and callback(t[i], i, callbackData) or t[i]
      if v then
        r = r + v
      end
    end
  else
    for key, value in pairs(t) do
      local v = callback and callback(value, key, callbackData) or value
      if v then
        r = r + v
      end
    end
  end
  return r
end

---Returns first element and its key for which callback returns a non-false value. Can work
---with both array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData
---@return T, TKey
function table.findFirst(t, callback, callbackData)
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      local e = t[i]
      if callback(e, i, callbackData) then
        return e, i
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key, callbackData) then
        return value, key
      end
    end
  end
  return nil, nil
end

---Returns an element and its key for which callback would return the highest numerical value. Can work
---with both array and non-array tables. If callback is missing, actual table elements will be compared.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): number
---@param callbackData TCallbackData
---@return T, TKey
function table.maxEntry(t, callback, callbackData)
  local r, k = nil, nil
  local v = -1/0
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      local l = callback and callback(t[i], i, callbackData) or t[i]
      if l > v then
        v = l
        r, k = t[i], i
      end
    end
  else
    for key, value in pairs(t) do
      local l = callback and callback(value, key, callbackData) or value
      if l > v then
        v = l
        r, k = value, key
      end
    end
  end
  return r, k
end

---Returns an element and its key for which callback would return the lowest numerical value. Can work
---with both array and non-array tables. If callback is missing, actual table elements will be compared.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): number
---@param callbackData TCallbackData
---@return T, TKey
function table.minEntry(t, callback, callbackData)
  local r, k = nil, nil
  local v = 1/0
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      local l = callback and callback(t[i], i, callbackData) or t[i]
      if l < v then
        v = l
        r, k = t[i], i
      end
    end
  else
    for key, value in pairs(t) do
      local l = callback and callback(value, key, callbackData) or value
      if l < v then
        v = l
        r, k = value, key
      end
    end
  end
  return r, k
end

---Runs callback for each item in a table. Can work with both array and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, key: TKey, callbackData: TCallbackData)
---@param callbackData TCallbackData
---@return table
function table.forEach(t, callback, callbackData)
  local n = #t
  if isArray(t, n) then
    for i = next(t), n do
      callback(t[i], i, callbackData)
    end
  else
    for key, value in pairs(t) do
      callback(value, key, callbackData)
    end
  end
end

---Creates a new table with unique elements from original table only. Optionally, a callback
---can be used to provide a key which uniqueness will be checked. Can work with both array
---and non-array tables.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t table<TKey, T>
---@param callback fun(item: T, key: TKey, callbackData: TCallbackData): any
---@param callbackData TCallbackData
---@return table<TKey, T>
function table.distinct(t, callback, callbackData)
  local N = #t
  local d = {}
  local r = {}
  if isArray(t, N) then
    local I = 1
    for key = next(t), N do
      local value = t[key]
      local u = callback and callback(value, key, callbackData) or value
      if u ~= nil then
        if not d[u] then
          d[u] = true
          r[I] = value
          I = I + 1
        end
      end
    end
  else
    for key, value in pairs(t) do
      local u = callback and callback(value, key, callbackData) or value
      if u ~= nil then
        if not d[u] then
          d[u] = true
          r[key] = value
        end
      end
    end
  end
  return r
end

---Merges tables into one big table. Requires tables to be arrays.
---@vararg table
---@return table
function table.chain(...)
  local ret = {}
  local I = 1
  local args = {...}
  for i = 1, #args do
    local t = args[i]
    local N = #t
    requireArray(t, N)
    for j = next(t), N do
      ret[I] = t[j]
      I = I + 1
    end
  end
  return ret
end

---Flattens table similar to JavaScript function with the same name. Requires an array.
---@param t any[]
---@param maxLevel integer? @Default value: 1.
---@return any[]
function table.flatten(t, maxLevel)
  local N = #t
  requireArray(t, N)
  maxLevel = maxLevel or 1

  local function flattenTo(ret, t, N, level)
    for key = next(t), N do
      local value = t[key]
      if table.isArray(value) and level < maxLevel then
        flattenTo(ret, value, #value, level + 1)
      else
        ret[#ret + 1] = value
      end
    end
  end

  local ret = {}
  flattenTo(ret, t, N, 0)
  return ret
end

---Creates a new table running in steps from `startingIndex` to `endingIndex`, including `endingIndex`.
---@generic T
---@generic TCallbackData
---@param endingIndex integer?
---@param startingIndex integer
---@param step integer?
---@param callback fun(index: integer, callbackData: TCallbackData): T
---@param callbackData TCallbackData
---@return T[]
---@overload fun(endingIndex: integer, callback: fun(index: integer, callbackData: any), callbackData: any)
---@overload fun(endingIndex: integer, startingIndex: integer, callback: fun(index: integer, callbackData: any), callbackData: any)
function table.range(endingIndex, startingIndex, step, callback, callbackData)
  if type(startingIndex) == 'function' then startingIndex, step, callback, callbackData = 1, 1, startingIndex, step
  elseif type(step) == 'function' then step, callback, callbackData = 1, step, callback end
  local r = _tnew(numberOfSteps(startingIndex, endingIndex, step), 0)
	for i = startingIndex, endingIndex, step do
		r[#r + 1] = callback(i, callbackData)
	end
  return r
end
