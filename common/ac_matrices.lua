do
  local _tm3, _tm4  

  ffi.cdef [[ 
  typedef struct {
    vec3 row1;
    vec3 row2;
    vec3 row3;
  } mat3x3;
  ]]

  local ctmat3x3 = ffi.typeof('mat3x3')
  mat3x3 = ffi.metatype('mat3x3', { 
    __tostring = function(v)
      return string.format('(%s,\n %s,\n %s)', v.row1, v.row2, v.row3)
    end,
    __index = {
      ismat3x3 = function(x) return ffi.istype(ctmat3x3, x) end,
      set = function(s, o)
        if not ffi.istype(ctmat3x3, o) then error('mat3x3 is required', 2) end
        s.row1:set(o.row1)
        s.row2:set(o.row2)
        s.row3:set(o.row3)
      end,
      clone = function(s)
        return mat3x3(s.row1, s.row2, s.row3)
      end,
      identity = function ()
        return mat3x3(vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1))
      end,
      tmp = function ()
        if _tm3 == nil then _tm3 = mat3x3() end
        return _tm3
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

  local ctmat4x4 = ffi.typeof('mat4x4')
  mat4x4 = ffi.metatype('mat4x4', { 
    __tostring = function(v)
      return string.format('(%s,\n %s,\n %s,\n %s)', v.row1, v.row2, v.row3, v.row4)
    end,
    __mul = function(v, u)
      return v:mul(u)
    end,
    __index = {
      ismat4x4 = function(x) return ffi.istype(ctmat4x4, x) end,
      set = function(s, o)
        if not ffi.istype(ctmat4x4, o) then error('mat4x4 is required', 2) end
        s.row1:set(o.row1)
        s.row2:set(o.row2)
        s.row3:set(o.row3)
        s.row4:set(o.row4)
      end,
      clone = function(s)
        return mat4x4(s.row1, s.row2, s.row3, s.row4)
      end,
      inverse = function(s)
        if s == nil then return nil end
        return ffi.C.lj_mat_inverse(s)
      end,
      inverseSelf = function(s)
        if s == nil then return nil end
        ffi.C.lj_mat_inverseself(s)
        return s
      end,
      normalize = function(s)
        if s == nil then return nil end
        return ffi.C.lj_mat_normalize(s)
      end,
      normalizeSelf = function(s)
        if s == nil then return nil end
        ffi.C.lj_mat_normalizeself(s)
        return s
      end,
      transpose = function(s)
        if s == nil then return nil end
        return ffi.C.lj_mat_transpose(s)
      end,
      transposeSelf = function(s)
        if s == nil then return nil end
        ffi.C.lj_mat_transposeself(s)
        return s
      end,
      mul = function(s, v)
        if s == nil then return nil end
        return ffi.C.lj_mat_mul(s, v)
      end,
      mulSelf = function(s, v)
        if s == nil then return nil end
        ffi.C.lj_mat_mulself(s, v)
        return s
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
      end,
      translation = function (vec)
        return ffi.C.lj_mat_translation(__util.ensure_vec3(vec))
      end,
      rotation = function (angle, vec)
        return ffi.C.lj_mat_rotation(tonumber(angle) or 0, __util.ensure_vec3(vec))
      end,
      euler = function (head, pitch, roll)
        return ffi.C.lj_mat_euler(tonumber(head) or 0, tonumber(pitch) or 0, tonumber(roll) or 0)
      end,
      scaling = function (vec)
        return ffi.C.lj_mat_scaling(__util.ensure_vec3(vec))
      end,
      tmp = function ()
        if _tm4 == nil then _tm4 = mat4x4() end
        return _tm4
      end
    }
  })
end
