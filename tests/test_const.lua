local MY_FIRST_CONST = const(17)
local MY_FIRST_FLAG = const(1)
local HAS_FLAG = const(function (x, FLAG)
  return bit.band(x, FLAG) ~= 0
end)
local ADD = const(function (x, y)
  return x + y
end)

expect(MY_FIRST_CONST, 17)
expect(MY_FIRST_FLAG, 1)
expect(HAS_FLAG(MY_FIRST_CONST, MY_FIRST_FLAG), true)
expect(ADD(MY_FIRST_CONST, MY_FIRST_FLAG), 18)
