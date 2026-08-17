local t = setmetatable({
  key0 = 'value0',
  key1 = 'value1',
  key2 = 'value2'
}, {
  __index = function (t, k)
    return rawget(t, k) or 'missing:'..tostring(k)
  end
})

expect(t.key0, 'value0')
expect(t.key15, 'missing:key15')
for k, v in pairs(t) do
  print(k, v)
end
