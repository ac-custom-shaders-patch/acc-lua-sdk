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

---Builds a list of points (vec2) arranged in a circle with poisson distribution.
---@param size integer @Number of points.
---@return vec2[]
function math.poissonSamplerCircle(size)
  if not poissonData then
    poissonData = __bound_array(ffi.typeof('vec2'), nil)
  end
  ffi.C.lj_poissonsampler_circle(poissonData, size)
  local result = {}
  for i = 1, #poissonData do
    result[i] = poissonData:get(i)
  end
  poissonData:clear()
  return result
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
---@param x number
---@param y number
---@param mix number
---@return number
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

---Converts degrees to radians.
---@param x number @Degrees.
---@return number @Radians.
function math.radians(x) return x * math.pi / 180 end

---Converts radians to degrees.
---@param x number @Radians.
---@return number @Degrees.
function math.degress(x) return x * 180 / math.pi end

---Checks if value is NaN.
---@param x number
---@return boolean
function math.isNaN(x) return x ~= x end

---@type number
math.NaN = 0/0

-- Value used by applyLag, if called a lot with the same lag, might be better to cache it.
---@param lag number
---@param dt number
---@return number
function math.lagMult(lag, dt)
  return math.saturateN((1.0 - lag) * dt * 60)
end

-- Simple smooth movement towards target value.
---@param value number
---@param target number
---@param lag number
---@param dt number
---@return number
function math.applyLag(value, target, lag, dt) 
  if lag <= 0 then return target end
  return value + (target - value) * math.lagMult(lag, dt)
end
