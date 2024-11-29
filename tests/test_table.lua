require('common/table')

expect(table.join({ 1, 2, 3 }), '1,2,3')
expect(table.join({ [0] = 1, 2, 3 }), '1,2,3')
expect(table.join({ a=1 }), 'a=1')
expect(table.slice({ 1, 2, 3 }, 1, nil, 3)[1], 1)
expect(table.slice({ 1, 2, 3 }, 2, nil, 3)[1], 2)
expect(table.slice({ 1, 2, 3 }, 3, nil, 3)[1], 3)
expect(table.slice({ [0] = 1, 2, 3 }, 2, nil, 3)[1], 3)
expect(table.reverse({1, 2, 3}), {3, 2, 1})
expect(table.reverse({1, 2, 3, 4}), {4, 3, 2, 1})
expect(table.reverse({[0] = 1, 2, 3}), {3, 2, 1})
expect(table.reverse({[0] = 1, 2, 3, 4}), {4, 3, 2, 1})

expect(table.contains({ [0] = 1, 2, 3 }, 1), true)
expect(table.contains({ [0] = 1, 2, 3 }, 0), false)
expect(table.removeItem({ [0] = 1, 2, 3 }, 1), true)

expect(table.slice({ 1, 2, 3 }, 1, nil, 3), { 1 })
expect(table.slice({ 1, 2, 3, 4, 5, 6 }, 1, nil, 3), { 1, 4 })
expect(table.slice({ 1, 2, 3, 4, 5, 6 }, 3, nil, 3), { 3, 6 })

expect(table.map({ 1, 2, 3 }, function (i) return i * 2 end), {2, 4, 6})
expect(table.map({ 1, 2, 3 }, function (i) return i * 2, i end), {2, 4, 6})
expect(table.map({ 1, 2, 3 }, function (i) return i, i * 2 end), {[2]=1, [4]=2, [6]=3})
expect(table.map({ 1, 2, 3 }, function (i) return i ~= 2 and i or nil end), {1, 3})
expect(table.map({ [0] = 1, 2, 3 }, function (i) return i ~= 2 and i or nil end), {1, 3})

expect(table.isArray({}), true)
expect(table.isArray({ 1, 2 }), true)
expect(table.isArray({ [1] = 1 }), true)
expect(table.isArray({ [1] = 1, [2] = 2 }), true)
expect(table.isArray({ [1] = 1, [2] = 2, [3] = 3 }), true)
expect(table.isArray({ [1] = 1, [2] = 2, [3] = 3, [4] = 4 }), true)
expect(table.isArray({ [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5 }), true)
expect(#{ [1] = 1, [2] = 2 }, 2)
expect(table.isArray({ [2] = 2 }), false)  -- difference is my and OpenResty logic
expect(require('table.isarray')({ [2] = 2 }), true)  -- I guess {[2]=2} is an array inside, but what does it matter if # returns 0?
expect(#{ [2] = 2 }, 0)
expect(table.isArray({ k = 'v' }), false)
expect(table.isArray({ 1, 2, k = 'v' }), false)

expect(table.isArray({ [1] = 1, [999] = 2 }), false)
expect(#{ [1] = 1, [999] = 2 }, 1)
expect(next({ [1] = 1, [999] = 2 }), 999)
expect(next({ [1] = 1, [999] = 2 }, 999), 1)
expect(next({ [1] = 1, [999] = 2 }, 1), nil)

expect(table.isArray({ [3] = 1, [2] = 2, [1] = 3 }), true)

-- expect(table.isArray({ [1] = 1, [2] = 2, [3] = 3 }), true)
expect(table.isArray({ [0] = 1, [1] = 2, [2] = 3 }), true)

expect(table.findFirst({1,2,3,0.3,4}, function (v) return v % 2 == 0 end), 2)
expect(table.maxEntry({1,2,3,0.3,4}), 4)
expect(table.minEntry({1,2,3,0.3,4}), 0.3)
expect(table.distinct({1,2,3,3,4}), {1,2,3,4})
expect(table.distinct({[0]=1,2,3,3,4}), {1,2,3,4})
-- expect(table.distinct({k=1,v=2,t=2}), {k=1,v=2})
expect(table.chain({1, 2}, {3, 4}), {1,2,3,4})
expect(table.chain({1, 2}, {3, 4}, {{5, 6}}), {1,2,3,4,{5,6}})
expect(table.flatten{ {1, 2}, {3, 4} }, {1,2,3,4})
expect(table.flatten({ {1, 2}, {3, {4, 5}} }), {1,2,3,{4,5}})
expect(table.flatten({ {1, 2}, {3, {4, 5}} }, 1), {1,2,3,{4,5}})
expect(table.flatten({ {1, 2}, {3, {4, 5}} }, 2), {1,2,3,4,5})

expect(table.same({}, {}), true)
expect(table.same({}, nil), false)
expect(table.same(nil, nil), true)
expect(table.same(nil, {}), false)
expect(table.same({1,2}, {1,2}), true)
expect(table.same({key=1,2}, {key=1,2}), true)
expect(table.same({key=1,2}, {key=1.1,2}), false)
expect(table.same({key=1.1,2,{a=5}}, {key=1.1,2,{a=5}}), true)
expect(table.same({[0]=1, 2}, {1}), false)
expect(table.same({[0]=1, 2}, {[0]=1, 2}), true)

local x = 0
local function counter()
  x = x + 1
  return x
end

local ordered = {
  k1 = counter(),
  k2 = counter(),
  k3 = counter(),
  k4 = counter(),
  k5 = counter(),
  k6 = counter(),
  k7 = counter(),
  k8 = counter(),
  k9 = counter(),
  k10 = counter(),
  k11 = counter(),
}
expect(ordered.k1, 1)
expect(ordered.k2, 2)
expect(ordered.k10, 10)