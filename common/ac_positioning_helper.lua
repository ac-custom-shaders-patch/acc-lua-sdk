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
  ---@param forceInactive boolean? @Prevents PositioningHelper from moving. Default value: `false`.
  ---@return boolean
  render = function(s, pos, forceInactive) 
    if not pos then error('Argument `pos` is required', 2) end
    return ffi.C.lj_positioninghelper_render__render(s, pos, forceInactive and true or false) 
  end,

  ---@param pos vec3
  ---@param look vec3
  ---@param forceInactive boolean? @Prevents PositioningHelper from moving. Default value: `false`.
  ---@return boolean
  renderAligned = function(s, pos, look, forceInactive) 
    if not pos then error('Argument `pos` is required', 2) end
    if not look then error('Argument `look` is required', 2) end
    return ffi.C.lj_positioninghelper_render_l__render(s, pos, __util.ensure_vec3(look), forceInactive and true or false)
  end,

  ---@param pos vec3
  ---@param look vec3
  ---@param up vec3
  ---@param forceInactive boolean? @Prevents PositioningHelper from moving. Default value: `false`.
  ---@return boolean
  renderFullyAligned = function(s, pos, look, up, forceInactive)
    if not pos then error('Argument `pos` is required', 2) end
    if not look then error('Argument `look` is required', 2) end
    if not up then error('Argument `up` is required', 2) end
    return ffi.C.lj_positioninghelper_render_lu__render(s, pos, __util.ensure_vec3(look), __util.ensure_vec3(up), forceInactive and true or false) 
  end,

  ---@return boolean
  anyHighlight = ffi.C.lj_positioninghelper_anyhighlight__render,

  ---@return boolean
  movingInScreenSpace = ffi.C.lj_positioninghelper_movinginscreenspace__render,
} })
