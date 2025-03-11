function __util.boundArray(ct, cb)
  return __util.lazy('lib_vector')(ct, cb, true)(16)
end

local __arrayTypeCache = {}
function __util.arrayType(ct)
  local cache = __arrayTypeCache[ct]
  if cache then return cache end
  local created = __util.lazy('lib_vector')(ct, nil, false)
  __arrayTypeCache[ct] = created
  return created
end

function __util.stealVector(s, steal)
  if not steal then return s.raw, s._size, -1 end
  local r0, r1, r2 = s.raw, s._size, s._cap
  s.raw, s._size, s._cap = nil, 0, 0
  return r0, r1, r2
end
