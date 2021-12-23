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
---Do not alter position and direction directly, or, if you do, do not cast it against lines or triangles, it stores some other precomputed values
---for faster and more accurate raycasting.
---@class ray
---@field pos vec3 @Ray origin.
---@field dir vec3 @Ray direction.
---@field length number @Ray length (used for physics raycasting, shorter rays are faster).
ffi.metatype('ray', { __index = {

  ---Ray/AABB intersection.
  ---@param min vec3 @AABB min corner.
  ---@param max vec3 @AABB max corner.
  ---@return boolean @True if there was an intersection.
  aabb = function(s, min, max) return ffi.C.lj_ray_aabb__render(s, __util.ensure_vec3(min), __util.ensure_vec3(max)) end,

  ---Ray/thick line intersection.
  ---@param from vec3 @Line, starting point.
  ---@param to vec3 @Line, finishing point.
  ---@param width number @Line width.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  line = function(s, from, to, width) return ffi.C.lj_ray_line__render(s, __util.ensure_vec3(from), __util.ensure_vec3(to), width) end,

  ---Ray/triangle intersection.
  ---@param p1 vec3 @Triangle, point A.
  ---@param p2 vec3 @Triangle, point B.
  ---@param p3 vec3 @Triangle, point C.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  triangle = function(s, p1, p2, p3) return ffi.C.lj_ray_triangle__render(s, __util.ensure_vec3(p1), __util.ensure_vec3(p2), __util.ensure_vec3(p3)) end,

  ---Ray/sphere intersection.
  ---@param center vec3 @Sphere, center.
  ---@param radius number @Sphere, radius.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  sphere = function(s, center, radius) return ffi.C.lj_ray_sphere__render(s, __util.ensure_vec3(center), tonumber(radius) or 0) end,

  ---Ray/track intersection.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  track = ffi.C.lj_ray_track__render,

  ---Ray/scene intersection (both with track and cars).
  ---@return number @Intersection distance, or -1 if there was no intersection.
  scene = ffi.C.lj_ray_scene__render,

  ---Ray/cars intersection.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  cars = ffi.C.lj_ray_cars__render,

  ---Ray/physics meshes intersection.
  ---@param outPosition vec3 @Optional vec3 to which contact point will be written.
  ---@param outNormal vec3 @Optional vec3 to which contact normal will be written.
  ---@return number @Intersection distance, or -1 if there was no intersection.
  physics = function(s, outPosition, outNormal) return ffi.C.lj_ray_physics__render(s, vec3.isvec3(outPosition) and outPosition or nil, vec3.isvec3(outNormal) and outNormal or nil) end,

  ---Distance between ray and a point.
  ---@param p vec3 @Point.
  ---@return number @Distance.
  distance = function(s, p) 
    local v = _rayVecTmp:set(p):sub(s.pos)
    local t = v:dot(s.dir)
    return p:distance(v:set(s.dir):scale(t):add(s.pos))
  end

} })

