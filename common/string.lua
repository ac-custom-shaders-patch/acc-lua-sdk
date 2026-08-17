-- Most of these functions are implemented on C++ side to keep things fast (things like string splitting work about ten times as fast there)

do
  -- Also, some new metamethods for extra niceness:
  local mt = getmetatable('')

  -- Index operator: `('abc')[1] == 'a'`
  mt.__index = function(str, i) return type(i) == 'number' and string.sub(str, i, i) or string[i] end
  
  -- String reversal: `-'abc' == 'cba'`
  -- mt.__unm = function(str, i) return string.reverse(str) end

  -- String multiplication: `'abc' * 2 == 'abcabc'`
  -- mt.__mul = function(str, i) return string.rep(str, i) end

  -- String contatenation (friendlier): `'abc' + nil == 'abcnil'`
  -- mt.__add = function(str, i) return str..tostring(i) end

  -- String format: `'%f' % 1 == '1.0000'`, `'%s, %s' % {1, 2} == '1, 2'`
  mt.__mod = function(str, i)
    return type(i) == 'table' and string.format(str, unpack(i)) or string.format(str, i)
  end

  -- For later:  
  -- mt.__call = function(str, i) return string.upper(str) end
end

local __urlmt

---Parses URL. Added in 0.3.0-preview238. Any missing components will be returned as empty strings. Generally, has
---semantics akin to `new URL()` from JavaScript, and uses the same underlying library for parsing. If failed to
---parse, returns `nil`.
---
---Calling `tostring()` on returned table will get the normalized URL back. Also,
---returned table has its own comparison, logic, allowing to compare different URLs together with ease.
---
---You can also alter any fields of the returned table and use `tostring()` to get the altered URL back. Note: if present,
---`hostname` will be used, so, override `hostname` and `port` instead of `host`. Also, `searchParams`, if present, will
---be used, ignoring `search`.
---
---Method `:getSearchParam()` is a simple shortcut returning the first item with matching key from `searchParams`.
---@param self string
---@param plusForSpaces boolean? @Use `'+'` for space symbol (works for URLs, but if a regular URL encoding is needed, might be getting in a way). Default value: `true`.
---@return nil|{hash: string, host: string, hostname: string, href: string, origin: string, password: string, pathname: string, port: string, protocol: string, search: string, username: string, searchParams: {[string]: string[]}, getSearchParam: (fun(s: self, key: string): string?)}
function string.urlParse(self, plusForSpaces) 
  if not __urlmt then
    __urlmt = {
      __tostring = function(v)
        return __util.native('__url_tostr', v)
      end,
      __eq = function(v, o)
        return __util.native('__url_tostr', v) == __util.native('__url_tostr', o)
      end,
      __index = {
        getSearchParam = function (v, k)
          local i = v.searchParams[k]
          return i and i[1]
        end
      }
    }
  end
  local parsed = __util.native('__parse_url', self, plusForSpaces)
  return parsed and setmetatable(parsed, __urlmt)
end

--[[ TODO: tests

ac.log(('test')[4])
ac.log(('test'):upper())
ac.log(('test'):rep(4))
ac.log(-'test')
ac.log('test' .. vec2(1, 2))
ac.log('test' + vec2(1, 2))
ac.log('test' * 2)
ac.log('%f' % 1.2345)
ac.log('%f, %f' % {1.2345, 2.3456})
]]