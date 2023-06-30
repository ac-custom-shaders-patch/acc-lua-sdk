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