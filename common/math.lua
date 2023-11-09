-- To make things simpler, Lua’s math module is extended here

local function __clamp(value, min, max)
  return value < min and min or value > max and max or value
end

---Takes value with even 0…1 distribution and remaps it to recreate a distribution
---similar to Gaussian’s one (with k≈0.52, a default value). Lower to make bell more
---compact, use a value above 1 to get some sort of inverse distibution.
---@param x number @Value to adjust.
---@param k number @Bell curvature parameter.
---@return number
function math.gaussianAdjustment(x, k)
  -- https://jsfiddle.net/9g03fkxm/
  k = k or 0.52
  local i = 1 - math.abs(x * 2 - 1)
  if i <= 0 then return x end
  return math.lerp((1 - i ^ k) * math.sign(x - 0.5), x * 2 - 1, math.log(i) * k * 0.5) * 0.5 + 0.5
end

---Builds a list of points arranged in a square with poisson distribution.
---@param size integer @Number of points.
---@param tileMode boolean? @If set to `true`, resulting points would be tilable without breaking poisson distribution.
---@return vec2[]
function math.poissonSamplerSquare(size, tileMode)
  size = math.floor(tonumber(size) or 0)
  if size < 1 then return {} end
  local arr = ffi.C.lj_poissonsampler_square(size, tileMode == true)
  local result = {}
  for i = 1, size do
    result[i] = arr[i - 1]:clone()
  end
  return result
end

---Builds a list of points arranged in a circle with poisson distribution.
---@param size integer @Number of points.
---@return vec2[]
function math.poissonSamplerCircle(size)
  size = math.floor(tonumber(size) or 0)
  if size < 1 then return {} end
  local arr = ffi.C.lj_poissonsampler_circle(size)
  local result = {}
  for i = 1, size do
    result[i] = arr[i - 1]:clone()
  end
  return result
end

---Generates a random number in [0, INT32_MAX) range. Can be a good argument for `math.randomseed()`.
---@return integer
function math.randomKey()
  return ffi.C.lj_random_seed()
end

---Generates random number based on a seed.
---@param seed integer|boolean|string @Seed.
---@return number @Random number from 0 to 1.
function math.seededRandom(seed)
  if type(seed) == 'string' then 
    seed = ffi.C.lj_checksumXXH(seed)
  elseif type(seed) ~= 'number' then
    seed = seed and 1 or 0
  end
  return ffi.C.lj_seed_random(seed)
end

---Rounds number, leaves certain number of decimals.
---@param number number
---@param decimals number? @Default value: 0 (rounding to a whole number).
---@return integer
function math.round(number, decimals)
  local c = 2^52 + 2^51
  if decimals then
    local scale = 10^decimals
    return ((number * scale + c) - c) / scale
  else
    return (number + c) - c
  end
end

--[[ …N functions are meant to work with numbers only, slightly faster ]]

---Clamps a number value between `min` and `max`.
---@param value number
---@param min number
---@param max number
---@return number
function math.clampN(value, min, max)
  return value < min and min or value > max and max or value
end

---Clamps a number value between 0 and 1.
---@param value number
---@return number
function math.saturateN(value) return value < 0 and 0 or value > 1 and 1 or value end

--[[ …V functions are meant to work with vectors only, slightly faster ]]

---Clamps a copy of a vector between `min` and `max`. To avoid making copies, use `vec:clamp(min, max)`.
---@generic T
---@param value T
---@param min any
---@param max any
---@return T
function math.clampV(value, min, max) return value:clone():clamp(min, max) end

---Clamps a copy of a vector between 0 and 1. To avoid making copies, use `vec:saturate()`.
---@generic T
---@param value T
---@return T
function math.saturateV(value) return value:clone():saturate() end

---Clamps value between `min` and `max`, returning `min` if `x` is below `min` or `max` if `x` is above `max`. Universal version, so might be slower.
---Also, if given a vector or a color, would make a copy of it.
---@generic T
---@param x T
---@param min any
---@param max any
---@return T
function math.clamp(x, min, max)
  if type(x) == 'number' then
    return __clamp(x, min, max)
  end

  local bn = type(min) == 'number'
  local bt = type(max) == 'number'
  if bn and bt then
    if vec3.isvec3(x) then 
      return vec3(__clamp(x.x, min, max), __clamp(x.y, min, max), __clamp(x.z, min, max)) 
    end  
    if vec2.isvec2(x) then 
      return vec2(__clamp(x.x, min, max), __clamp(x.y, min, max)) 
    end  
    if vec4.isvec4(x) then 
      return vec4(__clamp(x.x, min, max), __clamp(x.y, min, max), __clamp(x.z, min, max), __clamp(x.w, min, max)) 
    end  
    if rgb.isrgb(x) then 
      return rgb(__clamp(x.r, min, max), __clamp(x.g, min, max), __clamp(x.b, min, max)) 
    end  
    if rgbm.isrgbm(x) then 
      return rgbm(__clamp(x.r, min, max), __clamp(x.g, min, max), __clamp(x.b, min, max), __clamp(x.mult, min, max)) 
    end
  end

  local b = bn and min or x:type().new(min) 
  local t = bt and max or x:type().new(max) 

  if vec3.isvec3(x) then 
    return vec3(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y), __clamp(x.z, b.z, t.z)) 
  end
  if vec2.isvec2(x) then 
    return vec2(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y)) 
  end
  if vec4.isvec4(x) then 
    return vec4(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y), __clamp(x.z, b.z, t.z), __clamp(x.w, b.w, t.w)) 
  end
  if rgb.isrgb(x) then 
    return rgb(__clamp(x.r, b.r, t.r), __clamp(x.g, b.g, t.g), __clamp(x.b, b.b, t.b)) 
  end
  if rgbm.isrgbm(x) then 
    return rgbm(__clamp(x.r, b.r, t.r), __clamp(x.g, b.g, t.g), __clamp(x.b, b.b, t.b), __clamp(x.mult, b.mult, t.mult)) 
  end

  return __clamp(x, min, max)
end

---Clamps value between 0 and 1, returning 0 if `x` is below 0 or 1 if `x` is above 1. Universal version, so might be slower.
---Also, if given a vector or a color, would make a copy of it.
---@generic T
---@param x T
---@return T
function math.saturate(x) return math.clamp(x, 0, 1) end

---Returns a sing of a value, or 0 if value is 0.
---@param x number
---@return integer
function math.sign(x) if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end end

---Linear interpolation between `x` and `y` using `mix` (x * (1 - mix) + y * mix).
---@generic T
---@param x T
---@param y T
---@param mix number
---@return T
function math.lerp(x, y, mix) return x * (1 - mix) + y * mix end

---Returns 0 if value is less than v0, returns 1 if it’s more than v1, linear interpolation in-between.
---@param value number
---@param min number
---@param max number
---@return number
function math.lerpInvSat(value, min, max) return math.saturate((value - min) / (max - min)) end

---Smoothstep operation. More about it in [wiki](https://en.wikipedia.org/wiki/Smoothstep).
---@param x number
---@return number
function math.smoothstep(x) return x * x * (3 - 2 * x) end

---Like a smoothstep operation, but even smoother.
---@param x number
---@return number
function math.smootherstep(x) return x * x * x * (x * (x * 6 - 15) + 10) end

---Creates a copy of a vector and normalizes it. Consider avoiding making a copy with `vec:normalize()`.
---@generic T
---@param x T
---@return T
function math.normalize(x) return x:clone():normalize() end

---Creates a copy of a vector and runs a cross product on it. Consider avoiding making a copy with `vec:cross(otherVec)`.
---@param x vec3
---@return vec3
function math.cross(x, y) return x:clone():cross(y) end

---Calculates dot product of two vectors.
---@param x vec2|vec3|vec4
---@return number
function math.dot(x, y) return x:dot(y) end

---Calculates angle between vectors in radians.
---@param x vec2|vec3|vec4
---@return number @Radians.
function math.angle(x, y) return x:angle(y) end

---Calculates distance between vectors.
---@param x vec2|vec3|vec4
---@return number
function math.distance(x, y) return x:distance(y) end

---Calculates squared distance between vectors (slightly faster without taking a square root).
---@param x vec2|vec3|vec4
---@return number
function math.distanceSquared(x, y) return x:distanceSquared(y) end

---Creates a copy of a vector and projects it onto a different vector. Consider avoiding making a copy with `vec:project(otherVec)`.
---@generic T
---@param x T
---@return T
function math.project(x, y) return x:clone():project(y) end

function math.radians(x) return x * math.pi / 180 end
function math.degress(x) return x * 180 / math.pi end

---Checks if value is not-a-number.
---@param x number
---@return boolean
function math.isnan(x) return x ~= x end

---Checks if value is positive or negative infinity.
---@param x number
---@return boolean
function math.isinf(x) return x == math.huge or x == -math.huge end

---Checks if value is finite (not infinite or nan).
---@param x number
---@return boolean
function math.isfinite(x) x = tonumber(x) return x ~= nil and not math.isnan(x) and not math.isinf(x) end

---@type number
math.nan = 0/0

-- For compatibility:

---@deprecated Use math.isnan instead.
function math.isNaN(x) return x ~= x end

---@deprecated Use math.nan instead.
math.NaN = 0/0

-- Value used by applyLag, if called a lot with the same lag, might be better to cache it.
---@param lag number
---@param dt number
---@return number
function math.lagMult(lag, dt)
  return math.saturateN((1.0 - lag) * dt * 60)
end

-- Simple smooth movement towards target value.
---@generic T : number|vec2|vec3|vec4
---@param value T
---@param target T
---@param lag number
---@param dt number
---@return T
function math.applyLag(value, target, lag, dt) 
  if lag <= 0 then return target end
  if type(value) == 'number' then
    return value + (target - value) * math.lagMult(lag, dt)
  elseif type(value.scale) == 'function' then
    return (target - value):scale(math.lagMult(lag, dt)):add(value)
  else
    error('Wrong type', 2)
  end
end
