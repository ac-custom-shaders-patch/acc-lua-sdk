require('common/internal')
require('common/math')

expect(__util.json(false), 'false')
expect(__util.json(nil), 'null')
expect(__util.json({ 'hello', 'world' }), '["hello","world"]')
expect(__util.json({ 'he"llo', 'wo\nr\tl\rd' }), '["he\\"llo","wo\\nr\\tl\\rd"]')
expectOneOf(__util.json({ key = 123, key2 = math.NaN }), {
  '{\"key\":123,\"key2\":null}',
  '{\"key2\":null,\"key\":123}'
})

local t = { 1, 2 }
table.insert(t, t)
expect(__util.json(t), '[1,2,null]')