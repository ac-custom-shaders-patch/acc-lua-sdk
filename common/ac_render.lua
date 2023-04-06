__source 'lua/api_render.cpp'
__namespace 'render'

require './ac_render_enums'
require './ac_render_shader'


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
  blendMode: render.BlendMode = render.BlendMode.AlphaBlend "Blend mode. Default value: `render.BlendMode.AlphaBlend`.",
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
