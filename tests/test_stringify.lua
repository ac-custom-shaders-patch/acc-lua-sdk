function ss(value)
  return stringify(value, true)
end

function sn(value)
  return stringify(value, false)
end

function sl(value)
  return stringify.parse(stringify(value))
end

expect(ss(nil), 'nil')
expect(ss(0), '0')
expect(ss(0.5), '0.5')
expect(ss(-0.5e19), '-5e+18')
expect(ss(true), 'true')
expect(ss(false), 'false')
expect(ss('test'), '"test"')
expect(ss('"t\\est"'), '"\\"t\\\\est\\""')
expect(ss('"t\\e\nst"'), '"\\"t\\\\e\\\nst\\""')
expect(ss('"t\\e\tst"'), '"\\"t\\\\e\\9st\\""')
expect(sl('"t\\e\ns\tt"'), '"t\\e\ns\tt"')

expect(ss(vec2(1, 2)), 'vec2(1,2)')
expect(ss(vec3(1.5, 2, 4)), 'vec3(1.5,2,4)')
expect(ss(vec4(1.5, 2, 4, 10)), 'vec4(1.5,2,4,10)')
expect(ss(rgb(1.5, 2, 4)), 'rgb(1.5,2,4)')
expect(ss(rgbm(1.5, 2, 4, 10)), 'rgbm(1.5,2,4,10)')

expect(ss({ 1, 2, 3 }), '{1,2,3}')
expect(ss({ [0] = 1, 2, 3 }), '{1,2,3}')
expect(ss({ 1, '2', 3 }), '{1,"2",3}')
expect(ss({ 1, {2,4}, 3 }), '{1,{2,4},3}')
expect(ss({ key = 'value' }), '{key="value"}')
expect(ss({ _key = 'value' }), '{_key="value"}')
expect(ss({ ['0key'] = 'value' }), '{["0key"]="value"}')
expect(ss({ [false] = 'value' }), '{[false]="value"}')
expect(sl({ [false] = 'value' }), { [false] = 'value' })
expect(ss({ [{ a = 1 }] = 'value' }), '{[{a=1}]="value"}')

NIL = { __stringify = function() return 'NIL' end }
stringify.register('NIL', NIL)

expect(ss({ 1, {2,4}, 3, k = 'value' }), '{1,{2,4},3,k="value"}')
expect(ss({ [0] = 1, {2,4}, 3, k = 'value' }), '{1,{2,4},3,k="value"}')
expect(ss({ 1, NIL, 3 }), '{1,NIL,3}')
expect(sl({ 1, NIL, 3 }), { 1, NIL, 3 })
expect(sl({ NIL, NIL }), { NIL, NIL })
expect(sl(function () end), {type="function",name="nil",source="@./tests/_out.lua",what="Lua"})

local MyClass = class('MyClass')
function MyClass:initialize(value)
  self.key = value
end
function MyClass:__stringify(output, ptr, tab, depthLimit)
  output[ptr] = 'MyClass('
  ptr = stringify.substep(output, ptr + 1, self.key, tab, depthLimit)
  output[ptr] = ')'
  return ptr + 1
end
expect(MyClass('10').__stringify ~= nil, true)
expect(ss(MyClass('10')), 'MyClass("10")')

local MyClassAlt = class('MyClassAlt')
function MyClassAlt:initialize(value)
  self.key = value
end
function MyClassAlt:__stringify()
  return string.format('MyClassAlt(%s)', stringify(self.key))
end
expect(MyClassAlt('10').__stringify ~= nil, true)
expect(ss(MyClassAlt('10')), 'MyClassAlt("10")')


local t = {
  key = 'value',
  array = { 1, 2, 3, 4, 5, 6 },
  simple = { a = 1, b = 2, c = 3 },
  simple2 = { a = 1, b = 2, c = 3, 'first', 'items' },
  vec = vec3(1, 2, 3),
  some = { 1, { 2 , 4 }, 3, k = 'value' },
  MyClass(MyClassAlt(MyClass(17))),
  NIL,
}

expectError(function() stringify.parse(stringify(t)) end, 'Not available: MyClass')
expect(stringify.parse(stringify(t), { MyClass = MyClass, MyClassAlt = MyClassAlt }), t)
stringify.register(MyClass)
expect(stringify.parse(stringify(t), { MyClassAlt = MyClassAlt }), t)
expect(ss({ [vec4()] = {[2] = 'test'} }), '{[vec4()]={[2]="test"}}')

expect(stringify.parse(stringify(t), { MyClass = MyClass, MyClassAlt = MyClassAlt }), t)
-- print(stringify(stringify.parse(stringify(t), { MyClass = MyClass, MyClassAlt = MyClassAlt } )))
-- print(stringify(stringify.parse(stringify({
--   key = 'value',
--   array = { 1, 2, 3, 4, 5, 6 },
--   simple = { a = 1, b = 2, c = 3 },
--   simple2 = { a = 1, b = 2, c = 3, 'first', 'items' },
--   vec = vec3(1, 2, 3),
--   some = { 1, { 2 , 4 }, 3, k = 'value' },
--   [vec4()] = { [2] = 'test', [3] = { arr = { 4, 5, 6 } } },
-- }))))

local t = { 1, 2, 3 }
t[#t + 1] = t
expect(stringify(t, true), '{1,2,3,{type="circular reference"}}')

expectError(function() stringify.parse('{{') end, 'unexpected symbol near \'<eof>\'')

expectError(function() stringify.parse('{(function () print("escaped") end)()}') end, 'Not available: print')
expectError(function() stringify.parse('{(function () error("escaped") end)()}') end, 'Not available: error')
expectError(function() stringify.parse('{(function () error("escaped") end)()}', _G) end, 'escaped')
expectError(function() stringify.parse('{(function () io.write() end)()}') end, 'Not available: io')
expectError(function() stringify(stringify.parse('{((function (a) print("test") return a end):bind(1))()}')) end, 'Not available: print')

-- json = require('tests/data/json')
-- local d = json.decode(io.load('tests/data/traffic.json'))
-- io.save('tests/data/traffic.lua', stringify(d, true))

-- local s = 0
-- for i = 1, 1000 do
--   s = s + #json.encode(d)
-- end
-- print(s) -- 112984000, 3370 ms

-- local s = 0
-- for i = 1, 1000 do
--   s = s + #stringify(d, true)
-- end
-- print(s) -- 110776000, 971 ms

-- local j = io.load('tests/data/traffic.json')
-- local s = 0
-- for i = 1, 1000 do
--   s = s + #json.decode(j)
-- end
-- print(s) -- 0, 4506 ms

-- local j = io.load('tests/data/traffic.lua')
-- local s = 0
-- for i = 1, 1000 do
--   s = s + #parse(j)
-- end
-- print(s) -- 0, 2774 ms
