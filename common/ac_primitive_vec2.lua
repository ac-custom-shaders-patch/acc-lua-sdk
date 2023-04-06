local v2tmp1
local v2tmp2
local v2tmp3
local ctvec2 = ffi.typeof('vec2')

;--[[]]_G()

{
  new = function(x, y) 
    if type(x) ~= 'number' then 
      if type(x) == 'table' then
        return table.isArray(x) 
          and vec2(tonumber(x[1]) or 0, tonumber(x[2]) or 0)
          or vec2(tonumber(x.x) or 0, tonumber(x.y) or 0)
      elseif type(x) == 'string' then
        return vec2(x:numbers(2))
      elseif vec2.isvec2(x) then
        return vec2(x.x, x.y)
      end
      x = 0 
    end
    if type(y) ~= 'number' then y = x end
    return vec2(x, y)
  end,

  isvec2 = function(x) return ffi.istype(ctvec2, x) end,
  tmp = function() return v2tmp2 end,
  type = function(x) return vec2 end,
  clone = function(v) return vec2(v.x, v.y) end,
  unpack = function(v) return v.x, v.y end,
  table = function(v) return {v.x, v.y} end,

  intersect = function(p1, p2, p3, p4)
    local r = v2tmp3 or vec2()
    if ffi.C.lj_2d_segments_intersection(r, p1, p2, p3, p4) then
      v2tmp3 = nil
      return r
    else
      v2tmp3 = r
      return nil
    end
  end,

  set = function(v, x, y)
    if vec2.isvec2(x) then x, y = x.x, x.y
    elseif y == nil then y = x end
    v.x = x
    v.y = y
    return v
  end,

  setScaled = function(v, x, s)
    v.x = x.x * s
    v.y = x.y * s
    return v
  end,

  setLerp = function(v, a, b, k)
    v.x = math.lerp(a.x, b.x, k)
    v.y = math.lerp(a.y, b.y, k)
    return v
  end,

  copyTo = function(v, o)
    o.x = v.x
    o.y = v.y
  end,

  add = function(v, u, out)
    out = out or v
    if vec2.isvec2(u) then 
      out.x = v.x + u.x
      out.y = v.y + u.y
    else
      out.x = v.x + u
      out.y = v.y + u
    end
    return out
  end,

  addScaled = function(v, u, s, out)
    out = out or v
    out.x = v.x + u.x * s
    out.y = v.y + u.y * s
    return out
  end,

  sub = function(v, u, out)
    out = out or v
    if vec2.isvec2(u) then 
      out.x = v.x - u.x
      out.y = v.y - u.y
    else
      out.x = v.x - u
      out.y = v.y - u
    end
    return out
  end,

  mul = function(v, u, out)
    out = out or v
    out.x = v.x * u.x
    out.y = v.y * u.y
    return out
  end,

  div = function(v, u, out)
    out = out or v
    out.x = v.x / u.x
    out.y = v.y / u.y
    return out
  end,

  pow = function(v, u, out)
    out = out or v
    if type(u) == 'number' then
      out.x = v.x ^ u
      out.y = v.y ^ u
    else
      out.x = v.x ^ u.x
      out.y = v.y ^ u.y
    end
    return out
  end,

  scale = function(v, s, out)
    out = out or v
    out.x = v.x * s
    out.y = v.y * s
    return out
  end,

  min = function(v, s, out)
    out = out or v
    local sv = vec2.isvec2(s)
    out.x = math.min(v.x, sv and s.x or s)
    out.y = math.min(v.y, sv and s.y or s)
    return out
  end,

  max = function(v, s, out)
    out = out or v
    local sv = vec2.isvec2(s)
    out.x = math.max(v.x, sv and s.x or s)
    out.y = math.max(v.y, sv and s.y or s)
    return out
  end,

  saturate = function(v, out)
    out = out or v
    out.x = math.saturateN(v.x)
    out.y = math.saturateN(v.y)
    return out
  end,

  clamp = function(v, min, max, out)
    out = out or v
    out.x = math.clampN(v.x, min.x, max.x)
    out.y = math.clampN(v.y, min.y, max.y)
    return out
  end,

  length = function(v) return math.sqrt(v:lengthSquared()) end,
  lengthSquared = function(v) return v.x * v.x + v.y * v.y end,
  distance = function(v, u) return vec2.sub(v, u, v2tmp1):length() end,
  distanceSquared = function(v, u) return vec2.sub(v, u, v2tmp1):lengthSquared() end,
  closerToThan = function(v, u, d) return v:distanceSquared(u) < d * d end,
  angle = function(v, u) return math.acos(v:dot(u) / (v:length() + u:length())) end,
  dot = function(v, u) return v.x * u.x + v.y * u.y end,

  normalize = function(v, out)
    out = out or v
    local len = v:length()
    return len == 0 and v or v:scale(1 / len, out)
  end,

  lerp = function(v, u, t, out)
    out = out or v
    out.x = v.x + (u.x - v.x) * t
    out.y = v.y + (u.y - v.y) * t
    return out
  end,

  project = function(v, u, out)
    out = out or v
    local unorm = v2tmp1
    u:normalize(unorm)
    local dot = v:dot(unorm)
    out.x = unorm.x * dot
    out.y = unorm.y * dot
    return out
  end
}

;--[[]]_G()

v2tmp1 = vec2()
v2tmp2 = vec2()
