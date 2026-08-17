__source 'lua/api_common_mainthread.cpp'

require './ac_ray'
require './ac_display'
require './ac_render_enums'
require './ac_render_shader'
require './ac_extras_tracklines'

ffi.cdef [[ typedef struct { int __size; } noderef; ]]

__util.lazymod('lib_scene', ac, {
  'MeshVertex',
  'VertexBuffer',
  'IndicesBuffer',
  'GeometryShot',
  'emptySceneReference',
  'findAny',
  'findNodes',
  'findMeshes',
  'findSkinnedMeshes',
  'findByClass'
})

---Collect list of textures in KN5 file.
---@param kn5Filename string
---@param filter string? @Texture names filter. Default value: `'?'`.
---@return string[]? @Returns `nil` if there is no such file, no access to it or the file is damaged.
function ac.collectKN5TextureNames(kn5Filename, filter)
  return __util.native('kn5_texture_names', kn5Filename, filter)
end

---Collect list of material properties in KN5 file in a form of shader replacements config.
---@param kn5Filename string
---@param filter string? @Material names filter. Default value: `'?'`.
---@return string[]? @Returns `nil` if there is no such file, no access to it or the file is damaged.
function ac.collectKN5MaterialProperties(kn5Filename, filter)
  return __util.native('kn5_material_props', kn5Filename, filter)
end

---Adjusts LOD sliders from Graphics Adjustments live (adjustments remain in-place for as long as the script is alive).
---Pass `nil` to cancel a certain adjustment. Pass 1 for a regular LOD multiplier, or a value above 1 to increase details
---at distance. Pass `math.huge` to disable LODs.
---
---For scripts with Gameplay API access, there is also `ac.setExtraTrackLODMultiplier()` which would be applied on top of
---this multiplier.
---@param trackMultiplier number?
---@param carsMultiplier number?
function ac.overrideLODMultiplier(trackMultiplier, carsMultiplier)
  return __util.native('override_lod_multiplier', trackMultiplier, carsMultiplier)
end