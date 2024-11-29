expect((vec2(10, 12) + 4).y, 16)
expect(vec2(10, 12) > nil, false)
expect(vec2(10, 12) < nil, false)
expect(vec2(10, 12) == nil, false)
expect(nil == vec2(10, 12), false)
expect(nil == ffi.cast('vec2*', 0)[0], false)
expect(vec2.isvec2(ffi.cast('vec2*', 0)[0]), true)
expectError(function () return 1 + nil end, 'attempt to perform arithmetic on a nil value')
expectError(function () return nil + nil end, 'attempt to perform arithmetic on a nil value')
expectError(function () return vec2() + nil end, '.+ attempt to perform arithmetic on local')
expectError(function () return nil + vec2() end, '.+ attempt to index local')

expect(vec2 == ffi.typeof(vec2()), true)

expect(getmetatable(vec2).__stringify, nil)

local t = {}
t[tostring(vec2)] = true
expect(tostring(vec2), tostring(ffi.typeof(vec2(10, 12))))
expect(t[tostring(ffi.typeof(vec2(10, 12)))], true)

expect(vec2.isvec2(ffi.new(ffi.typeof(vec2()))), true)
-- print(tostring(ffi.typeof(vec2())))