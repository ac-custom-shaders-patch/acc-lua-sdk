__source 'lua/api_light.cpp'

require './ac_render'

ffi.cdef [[ 
typedef struct {
  void* host_;
  void* nativeLight0_;
  void* nativeLight1_;

  light_type lightType;
  vec3 position;
  rgb color;
  float specularMultiplier;
  float diffuseConcentration;
  float singleFrequency;
  float range;
  float rangeGradientOffset;
  float fadeAt;
  float fadeSmooth;

  vec3 direction;
  float spot;
  float spotSharpness;
  
  vec3 linePos;
  rgb lineColor;
  
  bool volumetricLight;
  bool skipLightMap;
  bool affectsCars;
  bool showInReflections;
  float longSpecular;
  
  bool shadows;
  bool shadowsStatic;
  bool shadowsHalfResolution;
  bool shadowsExtraBlur;
  
  float shadowsSpot;
  float shadowsRange;
  float shadowsBoost;
  float shadowsExponentialFactor;
  float shadowsClipPlane;
  float shadowsClipSphere;
  AC::CullMode shadowsCullMode;
  vec3 shadowsOffset;
} lightsource;
]] 

local __lightSourceKeepAlive = {}

---Light source on the scene. Starts working immediately after creation. Use `:dispose()` to remove it.
---@param lightType ac.LightType?
---@return ac.LightSource
function ac.LightSource(lightType)
  local created = ffi.C.lj_lightsource_new()
  created.lightType = lightType or ac.LightType.Regular
  __lightSourceKeepAlive[#__lightSourceKeepAlive + 1] = created
  return ffi.gc(created, ffi.C.lj_lightsource_gc)
end

---Light source on the scene. Starts working immediately after creation. Use `:dispose()` to remove it.
---@class ac.LightSource
---@field lightType ac.LightType @Type of light source.
---@field position vec3 @Light position.
---@field color rgb @Light color, go above 1 to make it brighter.
---@field specularMultiplier number @Specular multiplier. Lights with it set to 0 might be a bit faster to render, especially line lights.
---@field diffuseConcentration number @Diffuse concentration. If set to 1, surfaces facing perpendicular from light source would not get lit. If lower, they’d get more and more lit, and with 0 they’d get fully lit.
---@field singleFrequency number @Increase for single-frequency effect where only surfaces with colors matching that of light source would get illuminated.
---@field range number @Range in meters.
---@field rangeGradientOffset number @Point in range at which light would start to fade, from 0 to 1. Generally lights look better with it set to 0, but if you’re trying to keep range low and light bright, sometimes it helps to be able to increase it.
---@field fadeAt number @Distance in meters at which light fades (at that distance, it would have half of its original intensity).
---@field fadeSmooth number @Distance range in which light fades. Light starts fading at `fadeAt - fadeSmooth/2` and is fully gone at `fadeAt + fadeSmooth/2`.
---@field direction vec3 @Light direction.
---@field spot number @Spot angle in degrees, if set to 0, light works like a point light. Can misbehave if set above 350° (it can be above 180°, but keep in mind, anything above 170° wouldn’t really get any dynamic shadows).
---@field spotSharpness number @Spot sharpness. At 1, edges of spotlight are fully sharp. At 0, only point that is lit to 100% is the one in the center of light spot cone.
---@field linePos vec3 @For line lights, this is a secondary position (first is `position`).
---@field lineColor rgb @For line lights, this is a secondary color (first is `color`).
---@field volumetricLight boolean @Enable volumetric light effect (requires ExtraFX to work).
---@field skipLightMap boolean @Exclude light from bounced light effect of ExtraFX (the one where light bounces from horizontal surfaces around).
---@field affectsCars boolean @If set to `false`, light would not affect cars, can speed things up slightly.
---@field showInReflections boolean @If set to `false`, light would not appear in reflection cubemap speeding things up.
---@field longSpecular number @Controls long specular effect of ExtraFX (requires SSLR), which produces extra long going outside of light range speculars on wet surfaces.
---@field shadows boolean @Use dynamic shadows.
---@field shadowsStatic boolean @Static dynamic shadows exclude any dynamic objects, so they need a much lower refresh rate.
---@field shadowsHalfResolution boolean @Half-resolution dynamic shadows for extra blurriness.
---@field shadowsExtraBlur boolean @Additional shadow blurring.
---@field shadowsSpot number @If your spotlight is too wide and you can’t reduce it, alternatively you can use a lower spot angle for shadows alone. Wouldn’t look that great though sometimes.
---@field shadowsRange number @Range of shadows, by default matches range of light source. Because those are exponential shadow maps, adjusting it might help with visual quality.
---@field shadowsBoost number @Intensity boost for exponential shadow maps.
---@field shadowsExponentialFactor number @Exponential factor for exponential shadow maps.
---@field shadowsClipPlane number @Anything closer than this value would not appear in shadow maps (works like a clipping plane perpendicular to light direction).
---@field shadowsClipSphere number @Anything closer than this value would not appear in shadow maps (works like a clipping sphere around light position).
---@field shadowsCullMode render.CullMode @Culling mode for shadows. With exponential shadow maps it’s better not to do any culling, but just in case.
---@field shadowsOffset vec3 @Offset for shadow map camera position relative to light position. Might not look that pretty, so use with caution.
---@explicit-constructor ac.LightSource
ffi.metatype('lightsource', {
  __index = {
    ---Doesn’t do anything, kept for compatibility.
    ---@deprecated
    keepAlive = function (s) end,

    ---Link light to a node. Switches `position` and `direction` to operate in local coordinates.
    ---@param sceneReference ac.SceneReference? @Set to `nil` to unlink the light source.
    ---@return self
    linkTo = function (s, sceneReference) 
      ffi.C.lj_lightsource_settransformfrom(s, sceneReference)
      return s
    end,

    ---Removes light from the scene.
    dispose = function (s) table.removeItem(__lightSourceKeepAlive, s) ffi.C.lj_lightsource_dispose(s) end,
  }
})