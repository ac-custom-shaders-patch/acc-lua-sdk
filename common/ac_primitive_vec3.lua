local v3tmp1
local v3tmp2
local ctvec3 = ffi.typeof('vec3')

;--[[]]_G()

{
  new = function(x, y, z) 
    if type(x) ~= 'number' then
      if type(x) == 'table' then
        return table.isArray(x) 
          and vec3(tonumber(x[1]) or 0, tonumber(x[2]) or 0, tonumber(x[3]) or 0)
          or vec3(tonumber(x.x) or 0, tonumber(x.y) or 0, tonumber(x.z) or 0)
      elseif type(x) == 'string' then
        return vec3(x:numbers(3))
      elseif vec3.isvec3(x) then
        return vec3(x.x, x.y, x.z)
      end
      x = 0
    end
    if type(y) ~= 'number' then y = x end
    if type(z) ~= 'number' then z = y end
    return vec3(x, y, z) 
  end,

  isvec3 = function(x) return ffi.istype(ctvec3, x) end,
  tmp = function() return v3tmp2 end,
  type = function(x) return vec3 end,
  clone = function(v) return vec3(v.x, v.y, v.z) end,
  unpack = function(v) return v.x, v.y, v.z end,
  table = function(v) return {v.x, v.y, v.z} end,

  set = function(v, x, y, z)
    if type(x) ~= 'number' then x, y, z = x.x, x.y, x.z 
    elseif y == nil then y = x z = x end
    v.x = x
    v.y = y
    v.z = z
    return v
  end,

  setScaled = function(v, u, s, out)
    out = out or v
    v.x = u.x * s
    v.y = u.y * s
    v.z = u.z * s
    return out
  end,

  setLerp = function(v, a, b, k)
    local ki = 1 - k
    v.x = a.x * ki + b.x * k
    v.y = a.y * ki + b.y * k
    v.z = a.z * ki + b.z * k
    return v
  end,

  setCrossNormalized = function(v, v1, v2)
    local a, b, c = v2.x, v2.y, v2.z
    local x = b * v1.z - c * v1.y
    local y = c * v1.x - a * v1.z
    local z = a * v1.y - b * v1.x
    local s = math.sqrt(x^2 + y^2 + z^2)
    v.x = x / s
    v.y = y / s
    v.z = z / s
    return v
  end,

  copyTo = function(v, o)
    o.x = v.x
    o.y = v.y
    o.z = v.z
  end,

  add = function(v, u, out)
    out = out or v
    if type(u) == 'number' then
      out.x = v.x + u
      out.y = v.y + u
      out.z = v.z + u
    elseif u ~= nil then
      out.x = v.x + u.x
      out.y = v.y + u.y
      out.z = v.z + u.z
    end
    return out
  end,

  addScaled = function(v, u, s, out)
    out = out or v
    out.x = v.x + u.x * s
    out.y = v.y + u.y * s
    out.z = v.z + u.z * s
    return out
  end,

  sub = function(v, u, out)
    out = out or v
    if type(u) == 'number' then
      out.x = v.x - u
      out.y = v.y - u
      out.z = v.z - u
    elseif u ~= nil then
      out.x = v.x - u.x
      out.y = v.y - u.y
      out.z = v.z - u.z
    end
    return out
  end,

  mul = function(v, u, out)
    out = out or v
    out.x = v.x * u.x
    out.y = v.y * u.y
    out.z = v.z * u.z
    return out
  end,

  div = function(v, u, out)
    out = out or v
    out.x = v.x / u.x
    out.y = v.y / u.y
    out.z = v.z / u.z
    return out
  end,

  pow = function(v, u, out)
    out = out or v
    if type(u) == 'number' then
      out.x = v.x ^ u
      out.y = v.y ^ u
      out.z = v.z ^ u
    else
      out.x = v.x ^ u.x
      out.y = v.y ^ u.y
      out.z = v.z ^ u.z
    end
    return out
  end,

  scale = function(v, s, out)
    out = out or v
    out.x = v.x * s
    out.y = v.y * s
    out.z = v.z * s
    return out
  end,

  min = function(v, s, out)
    out = out or v
    local sv = vec3.isvec3(s)
    out.x = math.min(v.x, sv and s.x or s)
    out.y = math.min(v.y, sv and s.y or s)
    out.z = math.min(v.z, sv and s.z or s)
    return out
  end,

  max = function(v, s, out)
    out = out or v
    local sv = vec3.isvec3(s)
    out.x = math.max(v.x, sv and s.x or s)
    out.y = math.max(v.y, sv and s.y or s)
    out.z = math.max(v.z, sv and s.z or s)
    return out
  end,

  saturate = function(v, out)
    out = out or v
    out.x = math.saturateN(v.x)
    out.y = math.saturateN(v.y)
    out.z = math.saturateN(v.z)
    return out
  end,

  clamp = function(v, min, max, out)
    out = out or v
    out.x = math.clampN(v.x, min.x, max.x)
    out.y = math.clampN(v.y, min.y, max.y)
    out.z = math.clampN(v.z, min.z, max.z)
    return out
  end,

  length = function(v) return math.sqrt(v:lengthSquared()) end,
  lengthSquared = function(v) return v.x * v.x + v.y * v.y + v.z * v.z end,
  distance = function(v, u) return math.sqrt((v.x - u.x)^2 + (v.y - u.y)^2 + (v.z - u.z)^2) end,
  distanceSquared = function(v, u) return (v.x - u.x)^2 + (v.y - u.y)^2 + (v.z - u.z)^2 end,
  closerToThan = function(v, u, d) return v:distanceSquared(u) < d * d end,
  angle = function(v, u) return math.acos(v:dot(u) / (v:length() + u:length())) end,
  dot = function(v, u) return v.x * u.x + v.y * u.y + v.z * u.z end,

  normalize = function(v, out)
    out = out or v
    local len = v:length()
    return len == 0 and v or v:scale(1 / len, out)
  end,

  cross = function(v, u, out)
    out = out or v
    local a, b, c = v.x, v.y, v.z
    out.x = b * u.z - c * u.y
    out.y = c * u.x - a * u.z
    out.z = a * u.y - b * u.x
    return out
  end,

  lerp = function(v, u, t, out)
    out = out or v
    out.x = v.x + (u.x - v.x) * t
    out.y = v.y + (u.y - v.y) * t
    out.z = v.z + (u.z - v.z) * t
    return out
  end,

  project = function(v, u, out)
    out = out or v
    local unorm = v3tmp1
    u:normalize(unorm)
    local dot = v:dot(unorm)
    out.x = unorm.x * dot
    out.y = unorm.y * dot
    out.z = unorm.z * dot
    return out
  end,

  rotate = function(v, q, out)
    out = out or v
    local u, c, o = vec3(), vec3(), out
    u.x, u.y, u.z = q.x, q.y, q.z
    o.x, o.y, o.z = v.x, v.y, v.z
    u:cross(v, c)
    local uu = u:dot(u)
    local uv = u:dot(v)
    o:scale(q.w * q.w - uu)
    u:scale(2 * uv)
    c:scale(2 * q.w)
    return o:add(u:add(c))
  end,

  distanceToLine = function(v, a, b) return math.sqrt(ffi.C.lj_sqr_distance_to_line(v, a, b)) end,
  distanceToLineSquared = function(v, a, b) return ffi.C.lj_sqr_distance_to_line(v, a, b) end,
}

;--[[]]_G()

v3tmp1 = vec3()
v3tmp2 = vec3()