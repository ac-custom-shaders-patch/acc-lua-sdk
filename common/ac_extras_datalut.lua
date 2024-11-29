__source 'lua/api_extras_lut.cpp'

ffi.cdef [[ 
typedef struct {
  void* __lut0;
  void* __lut1;
  void* __lut2;
  vec2 __b_min;
  vec2 __b_max;
  int __size;
  bool useCubicInterpolation;
  bool extrapolate;
} lua_lut;

typedef struct {
  void* __lut0;
  void* __lut1;
  vec3 __b_min;
  vec3 __b_max;
  int __size;
  bool useBicubicInterpolation;
} lua_lut2d;
]]

ac.DataLUT11 = setmetatable({
  parse = function(data)
    local ret = ffi.C.lj_lut_parse(tostring(data))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut_gc) or nil
  end,
  load = function(filename)
    local ret = ffi.C.lj_lut_load(tostring(filename))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut_gc) or nil
  end,
  carData = function(carIndex, fileName)
    local ret = ffi.C.lj_lut_loadcardata(carIndex, tostring(fileName))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut_gc) or nil
  end
}, {
  __call = function()
    return ffi.gc(ffi.C.lj_lut_empty(), ffi.C.lj_lut_gc)
  end
})

ac.DataLUT21 = setmetatable({
  parse = function(data)
    local ret = ffi.C.lj_lut2d_parse(tostring(data))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut2d_gc) or nil
  end,
  load = function(filename)
    local ret = ffi.C.lj_lut2d_load(tostring(filename))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut2d_gc) or nil
  end,
  carData = function(carIndex, fileName)
    local ret = ffi.C.lj_lut2d_loadcardata(carIndex, tostring(fileName))
    return ret ~= nil and ffi.gc(ret, ffi.C.lj_lut2d_gc) or nil
  end
}, {
  __call = function()
    return ffi.gc(ffi.C.lj_lut2d_empty(), ffi.C.lj_lut2d_gc)
  end
})

---Simple 1D-to-1D lookup table wrapper, helps to deal with all those “.lut“ files in car data.
---@class ac.DataLUT11
---@field useCubicInterpolation boolean @Set to `true` to use cubic interpolation. Default value: `false` (linear interpolation).
---@field extrapolate boolean @Set to `true` to extrapolate if requested value is outside of the data available.
---@explicit-constructor ac.DataLUT11
ffi.metatype('lua_lut', {
  __len = function (s)
    if s.__size < 0 then
      ffi.C.lj_lut_refresh(s)
    end
    return s.__size
  end,
  __index = {
    __stringify = function (s, o, i)
      o[i] = 'ac.DataLUT11.parse("'
      o[i + 1] = s:serialize()
      o[i + 2] = '")'
      return i + 3
    end,

    ---Add a new value to LUT.
    ---@param input number
    ---@param output number
    ---@return ac.DataLUT11 @Returns self for easy chaining.
    add = function (s, input, output)
      ffi.C.lj_lut_add(s, tonumber(input) or 0, tonumber(output) or 0)
      return s
    end,

    ---Returns data boundaries.
    ---@return vec2 @Minimum input and output.
    ---@return vec2 @Maximum input and output.
    bounds = function (s)
      if s.__size < 0 then
        ffi.C.lj_lut_refresh(s)
      end
      return s.__b_min, s.__b_max
    end,

    ---Computes a LUT value using either linear or cubic interpolation (set field `ac.DataLUT11.useCubicInterpolation` to
    ---`true` to use cubic interpolation).
    ---@param input number
    ---@return number
    get = function (s, input)
      return ffi.C.lj_lut_get(s, tonumber(input) or 0)
    end,

    ---Returns input value of a certain point of a LUT, or `math.nan` if there is no such point.
    ---@param index number @0-based index.
    ---@return number
    getPointInput = function (s, index)
      return ffi.C.lj_lut_atkey(s, index)
    end,

    ---Returns output value of a certain point of a LUT, or `math.nan` if there is no such point.
    ---@param index number @0-based index.
    ---@return number
    getPointOutput = function (s, index)
      return ffi.C.lj_lut_atvalue(s, index)
    end,

    ---Convert LUT into a string, either in a short (inlined, for an INI config) or long (for a separate file) format.
    ---@param longFormat boolean? @Set to `true` to use long format. Default value: `false`.
    ---@return string
    serialize = function (s, longFormat)
      return __util.strrefr(ffi.C.lj_lut_serialize(s, longFormat == true))
    end,
  }
})

---Simple 2D-to-1D lookup table wrapper, helps to deal with all those “.2dlut“ files in car data. Tables can miss some values,
---such areas will be further interpolated.
---@class ac.DataLUT21
---@field useBicubicInterpolation boolean @Set to `true` to use bicubic interpolation. Default value: `false` (bilinear interpolation).
---@explicit-constructor ac.DataLUT21
ffi.metatype('lua_lut2d', {
  __len = function (s)
    if s.__size < 0 then
      ffi.C.lj_lut2d_refresh(s)
    end
    return s.__size
  end,
  __index = {
    __stringify = function (s, o, i)
      o[i] = 'ac.DataLUT21.parse("'
      o[i + 1] = s:serialize()
      o[i + 2] = '")'
      return i + 3
    end,

    ---Returns data boundaries.
    ---@return vec3 @Minimum input (X, Y) and output (Z).
    ---@return vec3 @Maximum input (X, Y) and output (Z).
    bounds = function (s)
      if s.__size < 0 then
        ffi.C.lj_lut2d_refresh(s)
      end
      return s.__b_min, s.__b_max
    end,

    ---Add a new value to a 2D LUT.
    ---@param input vec2
    ---@param output number
    ---@return ac.DataLUT21 @Returns self for easy chaining.
    add = function (s, input, output)
      ffi.C.lj_lut2d_add(s, __util.ensure_vec2(input), tonumber(output) or 0)
      return s
    end,

    ---Computes a LUT value using either bilinear or bicubic interpolation (set field `ac.DataLUT21.useBicubicInterpolation` to
    ---`true` to use bicubic interpolation).
    ---@param input vec2
    ---@return number
    get = function (s, input)
      return ffi.C.lj_lut2d_get(s, __util.ensure_vec2(input))
    end,

    ---Convert LUT into a string in a short (inlined, for an INI config) format.
    ---@return string
    serialize = function (s)
      return __util.strrefr(ffi.C.lj_lut2d_serialize(s))
    end,
  }
})