ffi.cdef [[ 
typedef struct {
  vec3 row1;
  vec3 row2;
  vec3 row3;
} mat3x3;
]]

mat3x3 = ffi.metatype('mat3x3', { 
  __tostring = function(v)
    return string.format('(%s,\n %s,\n %s)', v.row1, v.row2, v.row3)
  end,
  __index = {
    set = function(s, o)
      if not ffi.istype('mat3x3', o) then error('mat4x4 is required', 2) end
      s.row1:set(o.row1)
      s.row2:set(o.row2)
      s.row3:set(o.row3)
    end,
    clone = function(s)
      return mat3x3(s.row1, s.row2, s.row3)
    end,
    identity = function ()
      return mat3x3(vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1))
    end
  }
})

ffi.cdef [[ 
typedef struct {
  union { vec4 row1; vec3 side; };
  union { vec4 row2; vec3 up; };
  union { vec4 row3; vec3 look; };
  union { vec4 row4; vec3 position; };
} mat4x4;
]]

mat4x4 = ffi.metatype('mat4x4', { 
  __tostring = function(v)
    return string.format('(%s,\n %s,\n %s,\n %s)', v.row1, v.row2, v.row3, v.row4)
  end,
  __index = {
    set = function(s, o)
      if not ffi.istype('mat4x4', o) then error('mat4x4 is required', 2) end
      s.row1:set(o.row1)
      s.row2:set(o.row2)
      s.row3:set(o.row3)
      s.row4:set(o.row4)
    end,
    clone = function(s)
      return mat4x4(s.row1, s.row2, s.row3, s.row4)
    end,
    transformVectorTo = function(s, r, vec)
      r.x = s.row1.x * vec.x +  s.row2.x * vec.y + s.row3.x * vec.z
      r.y = s.row1.y * vec.x +  s.row2.y * vec.y + s.row3.y * vec.z
      r.z = s.row1.z * vec.x +  s.row2.z * vec.y + s.row3.z * vec.z
      return r
    end,
    transformPointTo = function(s, r, vec)
      r.x = s.row1.x * vec.x +  s.row2.x * vec.y + s.row3.x * vec.z + s.row4.x
      r.y = s.row1.y * vec.x +  s.row2.y * vec.y + s.row3.y * vec.z + s.row4.y
      r.z = s.row1.z * vec.x +  s.row2.z * vec.y + s.row3.z * vec.z + s.row4.z
      return r
    end,
    transformVector = function(s, vec)
      return s:transformVectorTo(vec3(), vec)
    end,
    transformPoint = function(s, vec)
      return s:transformPointTo(vec3(), vec)
    end,
    identity = function ()
      return mat4x4(vec4(1, 0, 0, 0), vec4(0, 1, 0, 0), vec4(0, 0, 1, 0), vec4(0, 0, 0, 1))
    end
  }
})
