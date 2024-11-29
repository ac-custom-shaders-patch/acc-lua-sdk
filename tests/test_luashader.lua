local function verifyPattern(template, params, texSlots, ret)
  local r = _lsfg(template, params, texSlots, ret)
  if type(loadstring(r)()) ~= 'function' then
    error('Does not compute: '..r)
  end
  return r
end

expect(verifyPattern({}, {}, {}), 'return function(d, params, C)\
end')

expect(verifyPattern({}, {values = {}}, {}), 'return function(d, params, C)\
end')

expect(verifyPattern({}, {values = {key = 1}}, {}), 'return function(d, params, C)\
local cb, values = d.d, params.values\
cb.key = values.key or 0\
end')

expect(verifyPattern({}, {values = {mat = mat4x4()}}, {}), 'return function(d, params, C)\
local cb, values = d.d, params.values\
if values.mat ~= nil then cb.mat = values.mat cb.mat:transposeSelf() end\
end')

local inp = {values = {mat = mat4x4.identity()}, directValuesExchange = true}
local ret = {d = {mat = 1}}
expect(verifyPattern({}, inp, {}, ret), 'return function(d, params, C)\
if type(params.values) == \"table\" then local cb, values = d.d, params.values\
if values.mat ~= nil then cb.mat = values.mat cb.mat:transposeSelf() end\
params.__values_bak = params.values params.values = cb end\
end')
expect(ret.d.mat.row4.w, 1)
expect(inp.values == ret.d, true)

expect(verifyPattern({}, {values = {}}, {'txDiffuse'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_1(1, tostring(textures.txDiffuse))\
end')

expect(verifyPattern({}, {values = {}}, {'txA', 'txB'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_2(1, tostring(textures.txA), tostring(textures.txB))\
end')

expect(verifyPattern({}, {values = {}}, {'txA', 'txB', 'txC'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_3(1, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC))\
end')

expect(verifyPattern({}, {values = {}}, {'txA', 'txB', 'txC', 'txD'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_4(1, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC), tostring(textures.txD))\
end')

expect(verifyPattern({}, {values = {}}, {'txA', 'txB', 'txC', 'txD', 'txE'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_5(1, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC), tostring(textures.txD), tostring(textures.txE))\
end')

expect(verifyPattern({}, {values = {}}, {'txA', 'txB', 'txC', 'txD', 'txE', 'txF'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_5(1, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC), tostring(textures.txD), tostring(textures.txE))\
C.lj_cshader_settexture_slot_1(6, tostring(textures.txF))\
end')

expect(verifyPattern({}, {values = {}}, {[3] = 'txA', [4] = 'txB', [5] = 'txC', [6] = 'txD', [7] = 'txE', [8] = 'txF', [9] = 'txG'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_5(3, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC), tostring(textures.txD), tostring(textures.txE))\
C.lj_cshader_settexture_slot_1(8, tostring(textures.txF))\
C.lj_cshader_settexture_slot_1(9, tostring(textures.txG))\
end')

expect(verifyPattern({delayed = true}, {values = {}}, {[3] = 'txA', [4] = 'txB', [5] = 'txC', [6] = 'txD', [7] = 'txE', [8] = 'txF', [9] = 'txG'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_delaytexture_slot_5(d.s, 3, tostring(textures.txA), tostring(textures.txB), tostring(textures.txC), tostring(textures.txD), tostring(textures.txE))\
C.lj_cshader_delaytexture_slot_1(d.s, 8, tostring(textures.txF))\
C.lj_cshader_delaytexture_slot_1(d.s, 9, tostring(textures.txG))\
end')

expect(verifyPattern({}, {values = {}}, {'txBase.1'}), 'return function(d, params, C)\
local textures = params.textures\
C.lj_cshader_settexture_slot_1(1, tostring(textures[\"txBase.1\"]))\
end')

-- expect(type(loadstring([[
-- return function(d, params, C)
-- C.lj_cshader_settexture_slot_1(0, tostring(params.textures.txBase.1))
-- cb, values = d.d, params.values
-- if values.gBlurRadius ~= nil then cb.gBlurRadius = values.gBlurRadius
-- end
-- d.blend_mode = tonumber(params.blendMode) or 0
-- end
-- ]])()), 'string')