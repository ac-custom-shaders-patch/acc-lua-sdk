require('common/ac_struct_item')

local function nextName()
  ac.StructItem.__lastIndex = (ac.StructItem.__lastIndex or 0) + 1
  return '_n'..tostring(ac.StructItem.__lastIndex)
end

function measureSize(layout)
  local name = nextName()
  ffi.cdef(ac.StructItem.__cdef(name, ac.StructItem.__build(layout), true))
  return ffi.sizeof(name)
end

---@generic T
---@param layout T
---@return T
function createItem(layout)
  local name = nextName()
  ffi.cdef(ac.StructItem.__cdef(name, ac.StructItem.__build(layout)))
  return ac.StructItem.__proxy(layout, ffi.new(name))
end

expect(ac.StructItem.__build({ 
  i00 = ac.StructItem.int32(),
  i01 = ac.StructItem.int32()
}), 'int i00;int i01;')
expect(measureSize('int i0;'), 4)
expect(measureSize('int i0;int i1;'), 8)

expect(ac.StructItem.__build({ 
  i10 = ac.StructItem.double(),
  i11 = ac.StructItem.int32()
}), 'double i10;int i11;')
expect(measureSize('uint16_t i0;uint16_t i1;uint16_t i2;'), 6)
expect(measureSize('double i0;int i1;'), 12)

expect(ac.StructItem.__build({ 
  i20 = ac.StructItem.string(20),
  i21 = ac.StructItem.double(),
  i22 = ac.StructItem.int32()
}), 'double i21;int i22;char i20[20];')
expect(measureSize('char i0[20];double i1;int i2;'), 32)

expect(ac.StructItem.__build({ 
  i20 = ac.StructItem.string(20),
  i21 = ac.StructItem.byte(),
  i22 = ac.StructItem.int32(),
  i23 = ac.StructItem.double()
}), 'double i23;int i22;uint8_t i21;char i20[20];')
expect(measureSize('char i20[20];int i22;double i23;bool i21;'), 33)

expect(ac.StructItem.__build({ 
  i20 = ac.StructItem.string(20),
  i21 = ac.StructItem.byte(),
  i22 = ac.StructItem.array(ac.StructItem.int32(), 4),
  i23 = ac.StructItem.double()
}), 'double i23;int i22[4];uint8_t i21;char i20[20];')


ffi.cdef[[ typedef struct { char c[8]; int v; } str_test; ]]
str = ffi.new('str_test')
str.v = 123456789
expect(str.v, 123456789)
str.c = 'hello world hello world'
expect(str.v, 123456789)
expect(__util.ffistrsafe(str.c, 8), 'hello wo')
str.c = 'hello'
expect(str.v, 123456789)
expect(__util.ffistrsafe(str.c, 8), 'hello')


str = createItem({ i20 = ac.StructItem.string(4), i21 = ac.StructItem.unorm8(), i22 = ac.StructItem.norm8(), i23 = ac.StructItem.unorm16(), i24 = ac.StructItem.norm16() })
str.i20 = 'hello world'
str.i21 = 0.5
expect(str.i20, 'hell')
expect(str.i20, 'hell')
expect(str.i20, 'hell')
expect(str.i20, 'hell')
expectClose(str.i21, 0.5, 1/255)

str.i21 = -1 expect(str.i21, 0)
str.i21 = 0 expect(str.i21, 0)
str.i21 = 1 expect(str.i21, 1)
str.i21 = 2 expect(str.i21, 1)
str.i21 = 0.123 expectClose(str.i21, 0.123, 1/255)

str.i22 = -2 expect(str.i22, -1)
str.i22 = -1 expect(str.i22, -1)
str.i22 = 0 expect(str.i22, 0)
str.i22 = 1 expect(str.i22, 1)
str.i22 = 2 expect(str.i22, 1)
str.i22 = 0.123 expectClose(str.i22, 0.123, 1/127)

str.i23 = -1 expect(str.i23, 0)
str.i23 = 0 expect(str.i23, 0)
str.i23 = 1 expect(str.i23, 1)
str.i23 = 2 expect(str.i23, 1)
str.i23 = 0.123 expectClose(str.i23, 0.123, 1/65e3)

str.i24 = -2 expect(str.i24, -1)
str.i24 = -1 expect(str.i24, -1)
str.i24 = 0 expect(str.i24, 0)
str.i24 = 1 expect(str.i24, 1)
str.i24 = 2 expect(str.i24, 1)
str.i24 = 0.123 expectClose(str.i24, 0.123, 1/35e3)
-- expect(str.l, nil)


expect(ac.StructItem.__build({
  ac.StructItem.key('mystruct'),
  i30 = ac.StructItem.string(21),
  i31 = ac.StructItem.vec3(),
  i32 = ac.StructItem.vec2(),
  i33 = ac.StructItem.vec4(),
  i34 = ac.StructItem.rgb(),
  i35 = ac.StructItem.rgbm(),
  i36 = ac.StructItem.hsv(),
  i37 = ac.StructItem.quat(),
}), 'vec4 i33;rgbm i35;quat i37;vec3 i31;rgb i34;hsv i36;vec2 i32;char i30[21];//mystruct')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  ac.StructItem.key('mystruct'),
  i30 = ac.StructItem.float(),
  i31 = ac.StructItem.vec3(),
})})[2]), '0:1\n4:1\n8:1\n12:1')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i30 = ac.StructItem.string(21),
  i31 = ac.StructItem.int16(),
  i32 = ac.StructItem.byte(),
  i33 = ac.StructItem.char(),
  i34 = ac.StructItem.double(),
  i35 = ac.StructItem.int32(),
  i36 = ac.StructItem.uint32(),
  i37 = ac.StructItem.norm16(),
  i38 = ac.StructItem.norm8(),
})})[2]), '0:0\n18:5\n22:3')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i34 = ac.StructItem.double(),
  i32 = ac.StructItem.float(),
  i38 = ac.StructItem.array(ac.StructItem.norm8(), 2),
})})[2]), '0:0\n8:1\n12:3\n13:3')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i38 = ac.StructItem.array(ac.StructItem.array(ac.StructItem.norm8(), 2), 3),
})})[2]), '0:3\n1:3\n2:3\n3:3\n4:3\n5:3')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i38 = ac.StructItem.struct({
    key = ac.StructItem.norm8()
  }),
})})[2]), '0:3')

expect(ac.StructItem.__cdef('SN', ac.StructItem.__build({
  i38 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.norm8()
  }), 2),
}), true), '#pragma pack(push, 1)\
typedef struct __declspec(align(1)){int8_t key;}__SN_1;\
typedef struct __declspec(align(1)){\
__SN_1 i38[2];\
\
} SN;\
#pragma pack(pop)')

expect(ac.StructItem.__cdef('SN', ac.StructItem.__build({
  i38 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.array(ac.StructItem.norm8(), 2)
  }), 2),
}), false), '#pragma pack(push, 1)\
typedef struct __declspec(align(1)){int8_t key[2];}__SN_1;\
#pragma pack(pop)\
typedef struct {\
__SN_1 i38[2];\
\
} SN;')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i38 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.norm8()
  }), 2),
})})[2]), '0:3\n1:3')

expect(ac.StructItem.__replayMixing(({ac.StructItem.__build({
  i38 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.array(ac.StructItem.norm8(), 2)
  }), 2),
})})[2]), '0:3\n1:3\n2:3\n3:3')

expect(ac.StructItem.__build({
  i31 = ac.StructItem.array(ac.StructItem.vec3(), 8),
}), 'vec3 i31[8];')

expect(ac.StructItem.__build({
  i31 = ac.StructItem.array(ac.StructItem.array(ac.StructItem.vec3(), 8), 2),
}), 'vec3 i31[2][8];')

expect(ac.StructItem.__cdef('SN', ac.StructItem.__build({
  i31 = ac.StructItem.struct({
    key = ac.StructItem.vec3(),
  }),
  i32 = ac.StructItem.array(ac.StructItem.struct({
    key2 = ac.StructItem.byte(),
  }), 4),
}), true), '#pragma pack(push, 1)\
typedef struct __declspec(align(1)){vec3 key;}__SN_1;typedef struct __declspec(align(1)){uint8_t key2;}__SN_2;\
typedef struct __declspec(align(1)){\
__SN_1 i31;__SN_2 i32[4];\
\
} SN;\
#pragma pack(pop)')

expect(ac.StructItem.__cdef('SN', ac.StructItem.__build({
  i31 = ac.StructItem.struct({
    key = ac.StructItem.vec3(),
  }),
  i32 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.vec3(),
  }), 4),
}), true), '#pragma pack(push, 1)\
typedef struct __declspec(align(1)){vec3 key;}__SN_1;\
typedef struct __declspec(align(1)){\
__SN_1 i31;__SN_1 i32[4];\
\
} SN;\
#pragma pack(pop)')


str = createItem({
  i31 = ac.StructItem.struct({
    key = ac.StructItem.vec3(),
  }),
  i32 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.vec3(),
  }), 4),
})
str.i31.key.y = 17
str.i32[2].key.z = 22
expect(str.i31.key.x, 0)
expect(str.i31.key.y, 17)
expect(str.i32[1].key.z, 0)
expect(str.i32[2].key.z, 22)

str = createItem({
  i31 = ac.StructItem.struct({
    key = ac.StructItem.mat4x4(),
  }),
  i32 = ac.StructItem.array(ac.StructItem.struct({
    key = ac.StructItem.mat3x3(),
  }), 4),
})
str.i31.key.position.y = 17
str.i31.key.position.z = 5
-- str.i31.key.position.z = nil
str.i32[2].key.row2.z = 22
expect(str.i31.key.position.x, 0)
expect(str.i31.key.position.y, 17)
-- expect(str.i31.key.position.z, 0)
expect(str.i32[1].key.row2.z, 0)
expect(str.i32[2].key.row2.z, 22)
