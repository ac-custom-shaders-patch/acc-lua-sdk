__source 'lua/api_render.cpp'
__namespace 'render'

require './ac_render_enums'
require './ac_render_shader'

---Affects positioning of debug shapes or meshes drawn next.
---@param pos vec3
---@param look vec3?
---@param up vec3?
---@param applySceneOriginOffset boolean? @Use it if your matrix is in world-space and not in graphics-space. Default value: `false`.
---@overload fun(transform: mat4x4, applySceneOriginOffset: boolean)
function render.setTransform(pos, look, up, applySceneOriginOffset)
  if mat4x4.ismat4x4(pos) then
    ac.debug('not not look', not not look)
    ffi.C.lj_setTransform_mat__render(pos, not not look)
  else
    ffi.C.lj_setTransform_vec__render(__util.ensure_vec3(pos), __util.ensure_vec3_nil(look), __util.ensure_vec3_nil(up),
      not not applySceneOriginOffset)
  end
end

---Draws a fullscreen pass with a custom shader. Shader is compiled at first run, which might take a few milliseconds.
---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
---while drawing will be skipped until shader is ready.
---
---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
---it a very effective tool for any custom drawing you might need to make.
---
---Example:
---```
---render.fullscreenPass({
---  async = true,
---  blendMode = render.BlendMode.BlendAdd,
---  textures = {
---    txInput1 = 'texture.png',  -- any key would work, but it’s easier to have a common prefix like “tx”
---    txInput2 = mediaPlayer,
---    txMissing = false
---  },
---  values = {
---    gValueColor = rgbm(1, 2, 0, 0.5),  -- any key would work, but it’s easier to have a common prefix like “g”
---    gValueNumber = math.random(),
---    gValueVec = vec2(1, 2),
---    gFlag = math.random() > 0.5
---  },
---  shader = [[
---    float4 main(PS_IN pin) { 
---      float4 in1 = txInput1.Sample(samAnisotropic, pin.Tex);
---      float4 in2 = txInput2.Sample(samAnisotropic, pin.Tex + gValueVec);
---      return pin.ApplyFog(gFlag ? in1 + in2 * gValueColor : in2);
---    }
---  ]]
---})
---```
---
---Consider wrapping result to `pin.ApplyFog(…)` to automatically apply configured fog.
---
---Tip: to simplify and speed things up, it might make sense to move table outside of a function to reuse it from frame
---to frame, simply accessing and updating textures, values and other parameters before call. However, make sure not to
---add new textures and values, otherwise it would require to recompile shader and might lead to VRAM leaks (if you would
---end up having thousands of no more used shaders). If you don’t have a working texture at the time of first creating
---that table, use `false` for missing texture value.
---
---Note: if shader would fail to compile, a C++ exception will be triggered, terminating script completely (to prevent AC 
---from crashing, C++ exceptions halt Lua script that triggered them until script gets a full reload).
---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
--[[@tableparam params {
  blendMode: render.BlendMode = render.BlendMode.AlphaBlend "Blend mode. Default value: `render.BlendMode.AlphaBlend`.",
  depthMode: render.DepthMode = render.DepthMode.ReadOnlyLessEqual "Depth mode. Default value: `render.DepthMode.ReadOnlyLessEqual`.",
  depth: number = nil "Optional depth in meters, to use hardware-accelerated depth clipping.",
  async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
  cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
  defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
  textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
  values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
  shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/fullscreen.fx”."
}]]
function render.fullscreenPass(params)
  local dc = __util.setShaderParams(params, 'fullscreen.fx', render.BlendMode.Opaque)
  if not dc then return false end
  ffi.C.lj_cshader_fullscreen__render(dc, tonumber(params.depthMode) or 4, tonumber(params.depth) or math.huge, vec4.isvec4(params.region) and params.region or nil)
  return true
end

---Draws a 3D quad with a custom shader. Shader is compiled at first run, which might take a few milliseconds.
---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
---while drawing will be skipped until shader is ready.
---
---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
---it a very effective tool for any custom drawing you might need to make.
---
---Example:
---```
---render.shaderedQuad({
---  async = true,
---  p1 = vec3(…),
---  p2 = vec3(…),
---  p3 = vec3(…),
---  p4 = vec3(…),
---  textures = {
---    txInput1 = 'texture.png',  -- any key would work, but it’s easier to have a common prefix like “tx”
---    txInput2 = mediaPlayer,
---    txMissing = false
---  },
---  values = {
---    gValueColor = rgbm(1, 2, 0, 0.5),  -- any key would work, but it’s easier to have a common prefix like “g”
---    gValueNumber = math.random(),
---    gValueVec = vec2(1, 2),
---    gFlag = math.random() > 0.5
---  },
---  shader = [[
---    float4 main(PS_IN pin) { 
---      float4 in1 = txInput1.Sample(samAnisotropic, pin.Tex);
---      float4 in2 = txInput2.Sample(samAnisotropic, pin.Tex + gValueVec);
---      return pin.ApplyFog(gFlag ? in1 + in2 * gValueColor : in2);
---    }
---  ]]
---})
---```
---
---Consider wrapping result to `pin.ApplyFog(…)` to automatically apply configured fog. To set blend mode and such, use `render.setBlendMode()`.
---
---Tip: to simplify and speed things up, it might make sense to move table outside of a function to reuse it from frame
---to frame, simply accessing and updating textures, values and other parameters before call. However, make sure not to
---add new textures and values, otherwise it would require to recompile shader and might lead to VRAM leaks (if you would
---end up having thousands of no more used shaders). If you don’t have a working texture at the time of first creating
---that table, use `false` for missing texture value.
---
---Note: if shader would fail to compile, a C++ exception will be triggered, terminating script completely (to prevent AC 
---from crashing, C++ exceptions halt Lua script that triggered them until script gets a full reload).
---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
--[[@tableparam params {
  p1: vec3 = vec3(0, 0, 0),
  p2: vec3 = vec3(0, 1, 0),
  p3: vec3 = vec3(1, 1, 0),
  p4: vec3 = vec3(1, 0, 0),
  async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
  cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
  defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
  textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
  values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
  shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/quad.fx”."
}]]
function render.shaderedQuad(params)
  local dc = __util.setShaderParams(params, 'quad.fx')
  if not dc then return false end
  ffi.C.lj_cshader_quad__render(dc, __util.ensure_vec3(params.p1), __util.ensure_vec3(params.p2), __util.ensure_vec3(params.p3), __util.ensure_vec3(params.p4))
  return true
end

---Describes a simple mesh with no tangent or extra vertex data, only positions and packed normals.
---@alias ac.SimpleMesh integer|table

---A namespace for working with `ac.SimpleMesh` entities.
ac.SimpleMesh = {}

---Creates a description of a simple mesh with a car shape. Usually is generated from LOD D if present and not too large, otherwise uses collider mesh.
---@param carIndex integer @0-based car index.
---@param includeDriver boolean? @Set to `true` to include simplified driver model as well. Default value: `false`.
---@return ac.SimpleMesh
function ac.SimpleMesh.carShape(carIndex, includeDriver)
  return (carIndex < 0 or carIndex > 255) and -1 or (includeDriver and carIndex + 256 or carIndex)
end

---Creates a description of a simple mesh with a car collider.
---@param carIndex integer @0-based car index.
---@return ac.SimpleMesh
function ac.SimpleMesh.carCollider(carIndex)
  return (carIndex < 0 or carIndex > 255) and -1 or carIndex + 512
end

---Creates a description of a simple mesh with a track line.
---@param lineType integer? @0 for ideal line, 1 for pits lane. Default value: 0.
---@param absolute number? @Width in meters. Default value: 10.
---@param relative number? @Width relative to track width. Default value: 0. Final width is a sum of the two.
---@return ac.SimpleMesh
function ac.SimpleMesh.trackLine(lineType, absolute, relative)
  return {lineType = lineType or 0, absolute = absolute or 10, relative = relative or 0}
end

---Draws a 3D mesh with a custom shader. Shader is compiled at first run, which might take a few milliseconds.
---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
---while drawing will be skipped until shader is ready.
---
---To position mesh, first call `render.setTransform()`.
---
---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
---it a very effective tool for any custom drawing you might need to make.
---
---Example:
---```
---render.mesh({
---  async = true,
---  mesh = ac.findMeshes(…),
---  textures = {
---    txInput1 = 'texture.png',  -- any key would work, but it’s easier to have a common prefix like “tx”
---    txInput2 = mediaPlayer,
---    txMissing = false
---  },
---  values = {
---    gValueColor = rgbm(1, 2, 0, 0.5),  -- any key would work, but it’s easier to have a common prefix like “g”
---    gValueNumber = math.random(),
---    gValueVec = vec2(1, 2),
---    gFlag = math.random() > 0.5
---  },
---  shader = [[
---    float4 main(PS_IN pin) { 
---      float4 in1 = txInput1.Sample(samAnisotropic, pin.Tex);
---      float4 in2 = txInput2.Sample(samAnisotropic, pin.Tex + gValueVec);
---      return pin.ApplyFog(gFlag ? in1 + in2 * gValueColor : in2);
---    }
---  ]]
---})
---```
---
---Consider wrapping result to `pin.ApplyFog(…)` to automatically apply configured fog. To set blend mode and such, use `render.setBlendMode()`.
---
---Tip: to simplify and speed things up, it might make sense to move table outside of a function to reuse it from frame
---to frame, simply accessing and updating textures, values and other parameters before call. However, make sure not to
---add new textures and values, otherwise it would require to recompile shader and might lead to VRAM leaks (if you would
---end up having thousands of no more used shaders). If you don’t have a working texture at the time of first creating
---that table, use `false` for missing texture value.
---
---Note: if shader would fail to compile, a C++ exception will be triggered, terminating script completely (to prevent AC 
---from crashing, C++ exceptions halt Lua script that triggered them until script gets a full reload).
---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
--[[@tableparam params {
  mesh: ac.SceneReference|ac.SimpleMesh = ac.SimpleMesh.carCollider(0),
  transform: mat4x4 = nil "Optional transform in world space. Does not apply to track spline.",
  async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
  cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
  defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
  textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
  values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
  shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/mesh.fx”."
}]]
function render.mesh(params)
  local dc = __util.setShaderParams(params, 'mesh.fx')
  if not dc then return false end
  local tr = nil ---@type mat4x4
  if params.transform then
    if mat4x4.ismat4x4(params.transform) then
      tr = params.transform
    elseif params.transform == 'original' then
      tr = mat4x4.tmp()
      tr.row1.x = math.huge
    end
  end
  if ffi.istype('noderef*', params.mesh) then
    ffi.C.lj_cshader_mesh__scene(dc, -2, params.mesh, tr, nil)
  elseif type(params.mesh) == 'number' then
    ffi.C.lj_cshader_mesh__scene(dc, params.mesh, nil, tr, nil)
  elseif type(params.mesh) == 'table' and params.mesh.lineType then
    local v = vec4.tmp():set(params.mesh.absolute, params.mesh.relative, 0, 0)
    ffi.C.lj_cshader_mesh__scene(dc, 768 + params.mesh.lineType, nil, tr, v)
  else
    error('Incorrect `mesh` parameter', 2)
  end
  return true
end

