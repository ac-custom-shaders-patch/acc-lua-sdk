require('common/function')


local function sum(a, b, c, d)
  return a + b + c + d
end

expect(sum(1, 10, 100, 1000), 1111)
expect(sum:bind(2)(20, 200, 2000), 2222)
expect(sum:bind(3, 30)(300, 3000), 3333)
expect(sum:bind(4, 40, 400)(4000), 4444)
expect(sum:bind(5, 50, 500, 5000)(), 5555)


