expect((vec2(10, 12) + 4).y, 16)
expect(vec2(10, 12) > nil, false)
expect(vec2(10, 12) < nil, false)
expect(vec2(10, 12) == nil, false)
expect(nil == vec2(10, 12), false)
expect(nil == ffi.cast('vec2*', 0)[0], false)
expect(vec2.isvec2(ffi.cast('vec2*', 0)[0]), true)
