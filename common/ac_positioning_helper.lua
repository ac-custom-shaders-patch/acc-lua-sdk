__source 'apps/positioning_helper.cpp'
__namespace 'render'

require './ac_ray'

ffi.cdef [[ 
typedef struct {
  void* __car;
  uint __highlighted_axis_bits_;
  int __highlighted_rotational_axis_;
  bool __moving_active_;
  bool __rotating_active_;
  bool __relative_coords_;

  vec2 __rotating_start_pos_;
  vec3 __drag_start_origin_;
  ray __drag_start_onscreen_;
} positioning_helper;
]]

---@class render.PositioningHelper
render.PositioningHelper = ffi.metatype('positioning_helper', { __index = {

  ---@param pos vec3
  ---@param forceInactive boolean @Prevents PositioningHelper from moving.
  ---@return boolean
  render = function(s, pos, forceInactive) 
    return ffi.C.lj_positioninghelper_render__render(s, __util.ensure_vec3(pos), forceInactive and true or false) 
  end,

  ---@param pos vec3
  ---@param look vec3
  ---@param forceInactive boolean @Prevents PositioningHelper from moving.
  ---@return boolean
  renderAligned = function(s, pos, look, forceInactive) 
    return ffi.C.lj_positioninghelper_render_l__render(s, __util.ensure_vec3(pos), __util.ensure_vec3(look), forceInactive and true or false)
  end,

  ---@param pos vec3
  ---@param look vec3
  ---@param up vec3
  ---@param forceInactive boolean @Prevents PositioningHelper from moving.
  ---@return boolean
  renderFullyAligned = function(s, pos, look, up, forceInactive) 
    return ffi.C.lj_positioninghelper_render_lu__render(s, __util.ensure_vec3(pos), __util.ensure_vec3(look), __util.ensure_vec3(up), forceInactive and true or false) 
  end,

  ---@return boolean
  anyHighlight = ffi.C.lj_positioninghelper_anyhighlight__render,

  ---@return boolean
  movingInScreenSpace = ffi.C.lj_positioninghelper_movinginscreenspace__render,
} })
