__source 'lua/api_ray.cpp'
__namespace 'render'

ffi.cdef [[ 
typedef struct {
  vec3 pos;
  vec3 dir;
  vec3 _pad0;
  vec3 _pad1;
  float length;
} ray;
]]

local _rayVecTmp = vec3()

---Ray for simple geometric raycasting. Do not create ray manually, instead use `render.createRay(pos, dir, length)` or `render.createMouseRay()`.
---Do not alter direction directly, or, if you do, do not cast it against lines, triangles or meshes, it stores some other precomputed values
---for faster and more accurate raycasting.
---@class ray
---@field pos vec3 @Ray origin.
---@field dir vec3 @Ray direction.
---@field length number @Ray length (used for physics raycasting, shorter rays are faster).
ffi.metatype('ray', { __index = {

  ---Ray/AABB intersection. Doesn’t account for ray length.
  ---@param min vec3 @AABB min corner.
  ---@param max vec3 @AABB max corner.
  ---@return boolean @True if there was an intersection.
  ---@nodiscard
  aabb = function(s, min, max)
    return ffi.C.lj_ray_aabb__render(s, __util.ensure_vec3(min), __util.ensure_vec3(max))
  end,

  ---Ray/thick line intersection. Accounts for ray length (since 0.2.10).
  ---@param from vec3 @Line, starting point.
  ---@param to vec3 @Line, finishing point.
  ---@param width number @Line width.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  line = function(s, from, to, width)
    return ffi.C.lj_ray_line__render(s, __util.ensure_vec3(from), __util.ensure_vec3(to), width)
  end,

  ---Ray/plaane intersection. Accounts for ray length (since 0.2.10).
  ---@param planePoint vec3
  ---@param planeNormal vec3
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  plane = function(s, planePoint, planeNormal)
    return ffi.C.lj_ray_plane__render(s, __util.ensure_vec3(planePoint), __util.ensure_vec3(planeNormal))
  end,

  ---Ray/triangle intersection. Accounts for ray length (since 0.2.10).
  ---@param p1 vec3 @Triangle, point A.
  ---@param p2 vec3 @Triangle, point B.
  ---@param p3 vec3 @Triangle, point C.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  triangle = function(s, p1, p2, p3)
    return ffi.C.lj_ray_triangle__render(s, __util.ensure_vec3(p1), __util.ensure_vec3(p2), __util.ensure_vec3(p3))
  end,

  ---Ray/sphere intersection. Accounts for ray length (since 0.2.10), previously length was used for an early exit only.
  ---@param center vec3 @Sphere, center.
  ---@param radius number @Sphere, radius.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  sphere = function(s, center, radius)
    return ffi.C.lj_ray_sphere__render(s, __util.ensure_vec3(center), tonumber(radius) or 0)
  end,

  ---Ray/car collider intersection. Accounts for ray length (since 0.2.10).
  ---@param carIndex integer @0-based car index.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  carCollider = function(s, carIndex)
    return ffi.C.lj_ray_carcollider__render(s, tonumber(carIndex) or -1)
  end,

  ---Ray/track intersection. Accounts for ray length (since 0.2.10).
  ---@param culling integer? @Set to -1 to disable backface culling, or to 0 to hit backfaces only. Default value: 1.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  track = function (s, culling)
    return ffi.C.lj_ray_track__render(s, tonumber(culling) or 1)
  end,

  ---Ray/scene intersection (both with track and cars). Accounts for ray length (since 0.2.10).
  ---@param culling integer? @Set to -1 to disable backface culling, or to 0 to hit backfaces only. Default value: 1.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  scene = function (s, culling)
    return ffi.C.lj_ray_scene__render(s, tonumber(culling) or 1)
  end,

  ---Ray/cars intersection. Accounts for ray length (since 0.2.10). Casts a ray against actual cars visual 3D geometry,
  ---so it’s likely you don’t need it and would be happier with `:carCollider()`.
  ---@param culling integer? @Set to -1 to disable backface culling, or to 0 to hit backfaces only. Default value: 1.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  ---@nodiscard
  cars = function (s, culling)
    return ffi.C.lj_ray_cars__render(s, tonumber(culling) or 1)
  end,

  ---Ray/physics meshes intersection. Accounts for ray length.
  ---@param outPosition vec3? @Optional vec3 to which contact point will be written.
  ---@param outNormal vec3? @Optional vec3 to which contact normal will be written.
  ---@param includeNoise boolean? @Set to `true` to take procedural sine noise into account. Default value: `false`.
  ---@param backfaceCulling boolean? @Set to `true` to enable backface culling. Default value: `false`.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  physics = function(s, outPosition, outNormal, includeNoise, backfaceCulling)
    return ffi.C.lj_ray_physics__render(s, vec3.isvec3(outPosition) and outPosition or nil,
      vec3.isvec3(outNormal) and outNormal or nil, includeNoise == true, backfaceCulling == true)
  end,

  ---Distance between ray and a point.
  ---@param p vec3 @Point.
  ---@return number @Distance.
  ---@nodiscard
  distance = function(s, p) 
    local v = _rayVecTmp:set(p):sub(s.pos)
    local t = v:dot(s.dir)
    return p:distance(v:set(s.dir):scale(t):add(s.pos))
  end

} })

