local v4tmp1
local v4tmp2
local ctvec4 = ffi.typeof('vec4')

;--[[]]_G()

{
  new = function(x, y, z, w) 
    if vec3.isvec3(x) then return vec4(x.x, x.y, x.z, w or 0) end
    if vec3.isvec3(y) then return vec4(x or 0, y.x, y.y, y.z) end
    if type(x) ~= 'number' then 
      if type(x) == 'table' then
        return table.isArray(x) 
          and vec4(tonumber(x[1]) or 0, tonumber(x[2]) or 0, tonumber(x[3]) or 0, tonumber(x[4]) or 0)
          or vec4(tonumber(x.x) or 0, tonumber(x.y) or 0, tonumber(x.z) or 0, tonumber(x.w) or 0)
      elseif type(x) == 'string' then
        return vec4(x:numbers(4))
      elseif vec4.isvec4(x) then
        return vec4(x.x, x.y, x.z, x.w)
      end
      x = 0 
    end
    if type(y) ~= 'number' then y = x end
    if type(z) ~= 'number' then z = y end
    if type(w) ~= 'number' then w = z end
    return vec4(x, y, z, w) 
  end,

  isvec4 = function(x) return ffi.istype(ctvec4, x) end,
  tmp = function() return v4tmp2 end,
  type = function(x) return vec4 end,
  clone = function(v) return vec4(v.x, v.y, v.z, v.w) end,
  unpack = function(v) return v.x, v.y, v.z, v.w end,
  table = function(v) return {v.x, v.y, v.z, v.w} end,

  set = function(v, x, y, z, w)
    if vec4.isvec4(x) then x, y, z, w = x.x, x.y, x.z, x.w
    elseif y == nil then y = x z = x w = x end
    v.x = x
    v.y = y
    v.z = z
    v.w = w
    return v
  end,

  setScaled = function(v, u, s, out)
    out = out or v
    v.x = u.x * s
    v.y = u.y * s
    v.z = u.z * s
    v.w = u.w * s
    return out
  end,

  setLerp = function(v, a, b, k)
    v.x = math.lerp(a.x, b.x, k)
    v.y = math.lerp(a.y, b.y, k)
    v.z = math.lerp(a.z, b.z, k)
    v.w = math.lerp(a.w, b.w, k)
    return v
  end,

  copyTo = function(v, o)
    o.x = v.x
    o.y = v.y
    o.z = v.z
    o.w = v.w
  end,

  add = function(v, u, out)
    out = out or v
    if vec4.isvec4(u) then 
      out.x = v.x + u.x
      out.y = v.y + u.y
      out.z = v.z + u.z
      out.w = v.w + u.w
    else
      out.x = v.x + u
      out.y = v.y + u
      out.z = v.z + u
      out.w = v.w + u
    end
    return out
  end,

  addScaled = function(v, u, s, out)
    out = out or v
    out.x = v.x + u.x * s
    out.y = v.y + u.y * s
    out.z = v.z + u.z * s
    out.w = v.w + u.w * s
    return out
  end,

  sub = function(v, u, out)
    out = out or v
    if vec4.isvec4(u) then 
      out.x = v.x - u.x
      out.y = v.y - u.y
      out.z = v.z - u.z
      out.w = v.w - u.w
    else
      out.x = v.x - u
      out.y = v.y - u
      out.z = v.z - u
      out.w = v.w - u
    end
    return out
  end,

  mul = function(v, u, out)
    out = out or v
    out.x = v.x * u.x
    out.y = v.y * u.y
    out.z = v.z * u.z
    out.w = v.w * u.w
    return out
  end,

  div = function(v, u, out)
    out = out or v
    out.x = v.x / u.x
    out.y = v.y / u.y
    out.z = v.z / u.z
    out.w = v.w / u.w
    return out
  end,

  pow = function(v, u, out)
    out = out or v
    if type(u) == 'number' then
      out.x = v.x ^ u
      out.y = v.y ^ u
      out.z = v.z ^ u
      out.w = v.w ^ u
    else
      out.x = v.x ^ u.x
      out.y = v.y ^ u.y
      out.z = v.z ^ u.z
      out.w = v.w ^ u.w
    end
    return out
  end,

  scale = function(v, s, out)
    out = out or v
    out.x = v.x * s
    out.y = v.y * s
    out.z = v.z * s
    out.w = v.w * s
    return out
  end,

  min = function(v, s, out)
    out = out or v
    local sv = vec4.isvec4(s)
    out.x = math.min(v.x, sv and s.x or s)
    out.y = math.min(v.y, sv and s.y or s)
    out.z = math.min(v.z, sv and s.z or s)
    out.w = math.min(v.w, sv and s.w or s)
    return out
  end,

  max = function(v, s, out)
    out = out or v
    local sv = vec4.isvec4(s)
    out.x = math.max(v.x, sv and s.x or s)
    out.y = math.max(v.y, sv and s.y or s)
    out.z = math.max(v.z, sv and s.z or s)
    out.w = math.max(v.w, sv and s.w or s)
    return out
  end,

  saturate = function(v, out)
    out = out or v
    out.x = math.saturateN(v.x)
    out.y = math.saturateN(v.y)
    out.z = math.saturateN(v.z)
    out.w = math.saturateN(v.w)
    return out
  end,

  clamp = function(v, min, max, out)
    out = out or v
    out.x = math.clampN(v.x, min.x, max.x)
    out.y = math.clampN(v.y, min.y, max.y)
    out.z = math.clampN(v.z, min.z, max.z)
    out.w = math.clampN(v.w, min.w, max.w)
    return out
  end,

  length = function(v) return math.sqrt(v:lengthSquared()) end,
  lengthSquared = function(v) return v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w end,
  distance = function(v, u) return vec4.sub(v, u, v4tmp1):length() end,
  distanceSquared = function(v, u) return vec4.sub(v, u, v4tmp1):lengthSquared() end,
  closerToThan = function(v, u, d) return v:distanceSquared(u) < d * d end,
  angle = function(v, u) return math.acos(v:dot(u) / (v:length() + u:length())) end,
  dot = function(v, u) return v.x * u.x + v.y * u.y + v.z * u.z + v.w * u.w end,

  normalize = function(v, out)
    out = out or v
    local len = v:length()
    return len == 0 and v or v:scale(1 / len, out)
  end,

  lerp = function(v, u, t, out)
    out = out or v
    out.x = v.x + (u.x - v.x) * t
    out.y = v.y + (u.y - v.y) * t
    out.z = v.z + (u.z - v.z) * t
    out.w = v.w + (u.w - v.w) * t
    return out
  end,

  project = function(v, u, out)
    out = out or v
    local unorm = v4tmp1
    u:normalize(unorm)
    local dot = v:dot(unorm)
    out.x = unorm.x * dot
    out.y = unorm.y * dot
    out.z = unorm.z * dot
    out.w = unorm.w * dot
    return out
  end
}

;--[[]]_G()

v4tmp1 = vec4()
v4tmp2 = vec4()
