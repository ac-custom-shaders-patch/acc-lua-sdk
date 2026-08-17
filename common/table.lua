-- To make things simpler, Lua’s table module is extended here

-- local _tisarray = require('table.isarray')
local _tclear = require('table.clear')
local _tclone = require('table.clone')
local _tnkeys = require('table.nkeys')
local _tnew = require('table.new')

-- See table.isArray
local function __isArray(t, N)
  -- return type(t) == 'table' and _tisarray(t)
  -- return type(t) == 'table' and N == _tnkeys(t)  -- alternative implementation. note: table.nkeys iterates over all elements for counting 🙄
  -- return type(t) == 'table' and _tisarray(t) and N == _tnkeys(t)  -- might be faster with earlier check, but let’s play it safe
  if type(t) ~= 'table' then return false end
  local f = next(t)
  if type(f) ~= 'number' or f < 0 or f > N then return f == nil end
  local k = next(t, N > 0 and N or nil)  -- does iterate over things, but seems to be more efficient overall
  return k == nil or type(k) == 'number' and k > 0 and k < N  -- specially for {[1]=1,[2]=2} table (and similar ones), where N==2, but next(2) can return 1
end

local function __requireArray(t, N)
  if __isArray(t, N) then return end
  error('Array is required', 3)
end

local function __cloneCDataSafely(t)
  return t:clone()
end

local function __deepCopy(t, f)
  if type(t) ~= 'table' then
    if f and type(t) == 'cdata' then
      local s, v = pcall(__cloneCDataSafely, t)
      if s then return v end
    end
    return t
  end
  local r, n = {}, #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      r[i] = __deepCopy(t[i], f)
    end
  else
    for key, value in pairs(t) do
      r[key] = __deepCopy(value, f)
    end
  end
  return r
end

---Checks if table is an array or not. Arrays are tables that only have consecutive numeric keys. If this function returns `true`, it doesn’t mean
---underlying LuaJIT structure is exactly a dense array, but it does mean that it could be. For example, `{[2]=2, [1]=1}` is not a dense array from
---LuaJIT POV, but semantically it is, and so `table.isArray()` would return `true`.
---@param t table|any[]
---@return boolean
---@nodiscard
function table.isArray(t)
  if type(t) ~= 'table' then return false end
  local N = #t
  return __isArray(t, N)
end

---Creates a new table with preallocated space for given amount of elements.
---@param arrayElements integer @How many elements the table will have as a sequence.
---@param mapElements integer @How many other elements the table will have.
---@return table
---@nodiscard
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
---@return integer
---@nodiscard
function table.nkeys(t)
  return _tnkeys(t)
end

---Clones table using a fast LuaJIT call. Doesn’t clone any vectors or colors inside, but it is fast.
---@generic T
---@param t T
---@param deep nil|boolean|'full' @Set to `true` for deep cloning. Default value: `false`. Since 0.2.10, set to `'full'` to clone vectors or colors as well.
---@return T
---@nodiscard
function table.clone(t, deep)
  if deep then
    return __deepCopy(t, deep == 'full')
  else
    return _tclone(t)
  end
end

---Removes first item by value, returns true if any item was removed. Can work
---with both array and non-array tables.
---@generic T
---@param t table<any, T>
---@param item T
---@return boolean
function table.removeItem(t, item)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
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
---@param callbackData TCallbackData?
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
---@nodiscard
function table.contains(t, item)
  local N = #t
  if __isArray(t, N) then
    for key = next(t) or 1, N do
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
---@param t {[TKey]: T}
---@param filteringCallback nil|fun(item: T, key: TKey, callbackData: TCallbackData): boolean
---@param filteringCallbackData TCallbackData?
---@param randomDevice nil|fun(): number @Optional callback for generating random numbers. Needs to return a value between 0 and 1. If not set, default `math.random` is used.
---@return T
---@nodiscard
function table.random(t, filteringCallback, filteringCallbackData, randomDevice)
  local mrandom = randomDevice or math.random
  local N = #t
  local r, k = nil, nil
  if __isArray(t, N) then
    if filteringCallback == nil then
      k = mrandom(N)
      r = t[k]
    else
      local nc = 0
      for key = next(t) or 1, N do
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

---Returns a key of a given element, or `nil` if there is no such element in a table. Can work
---with both array and non-array tables.
---@generic T
---@generic TKey
---@param t {[TKey]: T}
---@param item T
---@return TKey|nil
---@nodiscard
function table.indexOf(t, item)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
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

---Returns true if tables contents are the same.
---@generic TKey
---@param t1 table?
---@param t2 table?
---@param deep boolean? @Default value: `true`.
---@return boolean
---@nodiscard
function table.same(t1, t2, deep)
  if t1 == t2 then
    return true
  end
  if type(t1) ~= 'table' or type(t2) ~= 'table' then
    return false
  end
  local n1 = #t1
  local n2 = #t2
  local a1 = __isArray(t1, n1)
  local a2 = __isArray(t2, n2)
  if a1 ~= a2 or n1 ~= n2 then
    return false
  end
  deep = deep ~= false
  if a1 then
    local s1 = next(t1)
    if s1 ~= next(t2) then return false end
    for i = s1 or 1, n1 do
      local v1 = t1[i]
      local v2 = t2[i]
      if v1 ~= v2 and (not deep or not table.same(v1, v2, deep)) then
        return false
      end
    end
  else
    if _tnkeys(t1) ~= _tnkeys(t2) then
      return false
    end
    for i, v1 in pairs(t1) do
      local v2 = t2[i]
      if v1 ~= v2 and (not deep or not table.same(v1, v2, deep)) then
        return false
      end
    end
    for i, _ in pairs(t2) do
      if t1[i] == nil then
        return false
      end
    end
  end
  return true
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
---@param t {[TKey]: T}
---@param itemsJoin string? @Default value: ','.
---@param keyValueJoin string? @Default value: '='.
---@param toStringCallback nil|fun(item: T, key: TKey, callbackData: TCallbackData): string
---@param toStringCallbackData TCallbackData?
---@overload fun(t: table, itemsJoin: string, toStringCallback: fun(item: any, key: any, callbackData: any), toStringCallbackData: any)
---@overload fun(t: table, toStringCallback: fun(item: any, key: any, callbackData: any), toStringCallbackData: any)
---@return TKey|nil
---@nodiscard
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
  if __isArray(t, N) then
    for key = next(t) or 1, N do
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
---@nodiscard
function table.slice(t, from, to, step)
  local N = #t
  __requireArray(t, N)
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
---@nodiscard
function table.reverse(t)
  local N = #t
  local ret = _tnew(N, 0)
  __requireArray(t, N)
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
---@param t {[TKey]: T}
---@param callback (fun(item: T, index: TKey, callbackData: TCallbackData): TReturnValue, TReturnKey?)|nil @Mapping callback.
---@param callbackData TCallbackData?
---@return {[TReturnKey]: TReturnValue}
---@nodiscard
function table.map(t, callback, callbackData)
  local ret = {}
  local N = #t
  local I = 1
  if __isArray(t, N) then
    for key = next(t) or 1, N do
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
---@param t {[TKey]: T}
---@param startingValue TData
---@param callback fun(data: TData, item: T, index: TKey, callbackData: TCallbackData): TData @Reduction callback.
---@param callbackData TCallbackData?
---@return TData
---@nodiscard
function table.reduce(t, startingValue, callback, callbackData)
  local N = #t
  if __isArray(t, N) then
    for key = next(t) or 1, N do
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): any @Filtering callback.
---@param callbackData TCallbackData?
---@return {[TKey]: T}
---@nodiscard
function table.filter(t, callback, callbackData)
  local ret = {}
  local N = #t
  if __isArray(t, N) then
    local I = 1
    for key = next(t) or 1, N do
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData?
---@return boolean
---@nodiscard
function table.every(t, callback, callbackData)
  local N = #t
  if __isArray(t, N) then
    for key = next(t) or 1, N do
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData?
---@return boolean
---@nodiscard
function table.some(t, callback, callbackData)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
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
---@param t {[TKey]: T}
---@param callback nil|fun(item: T, index: TKey, callbackData: TCallbackData): boolean @If not set, all elements will be counted.
---@param callbackData TCallbackData?
---@return integer
---@nodiscard
function table.count(t, callback, callbackData)
  local n, r = #t, 0
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      if not callback or callback(t[i], i, callbackData) then
        r = r + 1
      end
    end
  else
    for key, value in pairs(t) do
      if not callback or callback(value, key, callbackData) then
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData?
---@return integer
---@nodiscard
function table.sum(t, callback, callbackData)
  local n, r = #t, 0
  if __isArray(t, n) then
    for i = next(t) or 1, n do
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
---with both array and non-array tables. If nothing is found, returns `nil`.
---@generic T
---@generic TKey
---@generic TCallbackData
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): boolean
---@param callbackData TCallbackData?
---@return T, TKey
---@nodiscard
function table.findFirst(t, callback, callbackData)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      if callback(t[i], i, callbackData) then
        return t[i], i
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

---Returns first element and its key for which a certain property matches the value. If nothing is
---found, returns `nil`.
---@generic T
---@generic TKey
---@param t {[TKey]: T}
---@param key TKey
---@param value T
---@return T, TKey
---@nodiscard
function table.findByProperty(t, key, value)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      if t[i][key] == value then
        return t[i], i
      end
    end
  else
    for k, v in pairs(t) do
      if v[key] == value then
        return v, k
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): number?
---@param callbackData TCallbackData?
---@return T, TKey
---@nodiscard
function table.maxEntry(t, callback, callbackData)
  local r, k = nil, nil
  local v = -1/0
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      local l
      if callback then
        l = callback(t[i], i, callbackData)
      else
        l = t[i]
      end
      if l and l > v then
        v = l
        r, k = t[i], i
      end
    end
  else
    for key, value in pairs(t) do
      local l
      if callback then
        l = callback(value, key, callbackData)
      else
        l = value
      end
      if l and l > v then
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
---@param t {[TKey]: T}
---@param callback fun(item: T, index: TKey, callbackData: TCallbackData): number?
---@param callbackData TCallbackData?
---@return T, TKey
---@nodiscard
function table.minEntry(t, callback, callbackData)
  local r, k = nil, nil
  local v = 1/0
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
      local l
      if callback then
        l = callback(t[i], i, callbackData)
      else
        l = t[i]
      end
      if l and l < v then
        v = l
        r, k = t[i], i
      end
    end
  else
    for key, value in pairs(t) do
      local l
      if callback then
        l = callback(value, key, callbackData)
      else
        l = value
      end
      if l and l < v then
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
---@param t {[TKey]: T}
---@param callback fun(item: T, key: TKey, callbackData: TCallbackData)
---@param callbackData TCallbackData?
---@return table
function table.forEach(t, callback, callbackData)
  local n = #t
  if __isArray(t, n) then
    for i = next(t) or 1, n do
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
---@param t {[TKey]: T}
---@param callback nil|fun(item: T, key: TKey, callbackData: TCallbackData): any|nil
---@param callbackData TCallbackData?
---@return {[TKey]: T}
---@nodiscard
function table.distinct(t, callback, callbackData)
  local N = #t
  local d = {}
  local r = {}
  if __isArray(t, N) then
    local I = 1
    for key = next(t) or 1, N do
      local value = t[key]
      local u
      if callback then
        u = callback(value, key, callbackData)
      else
        u = value
      end
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
      local u
      if callback then
        u = callback(value, key, callbackData)
      else
        u = value
      end
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

---Finds first element for which `testCallback` returns true, returns index of an element before it.
---Elements should be ordered in such a way that there would be no more elements returning false to the right
---of an element returning true.
---
---If `testCallback` returns true for all elements, would return 0. If `testCallback` returns false for all,
---returns index of the latest element.
---@generic T
---@generic TCallbackData
---@param t T[]
---@param testCallback fun(item: T, index: integer, callbackData: TCallbackData): boolean
---@param testCallbackData nil|TCallbackData
---@return integer
---@nodiscard
function table.findLeftOfIndex(t, testCallback, testCallbackData)
  local n = #t
  __requireArray(t, n)
  local i = 0
  while n > 0 do
    local step = _mfloor(n / 2)
    if testCallback(t[i + step + 1], i + step + 1, testCallbackData) then
      n = step
    else
      i = i + step + 1
      n = n - step - 1
    end
  end
  return i
end

function table.chain(...)
  local ret = {}
  local I = 1
  for i = 1, select('#', ...) do
    local t = select(i, ...)
    if t then
      local N = #t
      if __isArray(t, N) then
        __requireArray(t, N)
        for j = next(t) or 1, N do
          ret[I] = t[j]
          I = I + 1
        end
      else
        for key, value in pairs(t) do
          ret[key] = value
        end
      end
    end
  end
  return ret
end

---Similar to JavaScript’s `Object.assign()`, works with tables and arrays, returns first argument (modified).
---@generic T
---@param target T
---@param ... table
---@return T
function table.assign(target, ...)
  local I = #target + 1
  for i = 1, select('#', ...) do
    local t = select(i, ...)
    if t then
      local N = #t
      if __isArray(t, N) then
        __requireArray(t, N)
        for j = next(t) or 1, N do
          target[I] = t[j]
          I = I + 1
        end
      else
        for key, value in pairs(t) do
          target[key] = value
        end
      end
    end
  end
  return target
end

---Flattens table similar to JavaScript function with the same name. Requires an array.
---@param t any[]
---@param maxLevel integer? @Default value: 1.
---@return any[]
---@nodiscard
function table.flatten(t, maxLevel)
  local N = #t
  __requireArray(t, N)
  maxLevel = maxLevel or 1

  local function flattenTo(ret, t, N, level)
    for key = next(t) or 1, N do
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
---If callback returns two values, second value is used as a key.
---@generic T
---@generic TCallbackData
---@param endingIndex integer?
---@param startingIndex integer
---@param step integer?
---@param callback fun(index: integer, callbackData: TCallbackData): T, integer|string?
---@param callbackData TCallbackData?
---@return T[]
---@overload fun(endingIndex: integer, callback: (fun(index: integer, callbackData: any): any, integer|string?), callbackData: any)
---@overload fun(endingIndex: integer, startingIndex: integer, callback: (fun(index: integer, callbackData: any): any, integer|string?), callbackData: any)
---@nodiscard
function table.range(endingIndex, startingIndex, step, callback, callbackData)
  if type(startingIndex) == 'function' then startingIndex, step, callback, callbackData = 1, 1, startingIndex, step
  elseif type(step) == 'function' then step, callback, callbackData = 1, step, callback end
  local r = _tnew(numberOfSteps(startingIndex, endingIndex, step), 0)
	for i = startingIndex, endingIndex, step do
		local v, k = callback(i, callbackData)
    r[k or (#r + 1)] = v
	end
  return r
end

---Creates a new table from iterator. Supports iterators returning one or two values (if two values are returned, first is considered the key,
---if not, values are simply added to a list).
---
---Example:
---```
---local t = table.build(ipairs({1, 2, 3, 4})) -- t is `{1, 2, 3, 4}`
---local t = table.build(pairs({a = 1, b = 2})) -- t is `{a = 1, b = 2}`
---```
---@generic T
---@param iterator fun(...): T
---@return T[]
---@nodiscard
function table.build(iterator, state, nextKey)
  local ret = {}
  local v
  while true do
    nextKey, v = iterator(state, nextKey)
    if not v then return ret end
    ret[nextKey] = v
  end
end
