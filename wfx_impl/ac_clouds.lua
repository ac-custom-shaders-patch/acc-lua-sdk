ffi.cdef [[
typedef struct {     
  rgb ambientColor;
  float frontlitMultiplier;

  float frontlitDiffuseConcentration;
  float backlitExponent;
  float backlitOpacityExponent;
  float backlitOpacityMultiplier;

  float backlitMultiplier;
  float specularPower;
  float specularExponent;
  float fogMultiplier;

  rgb baseColor;
  rgb extraDownlit;
  float lightSaturation;
  float ambientConcentration;
  float contourExponent;
  float contourIntensity;
  bool useSceneAmbient;
  float receiveShadowsOpacity;
  float alphaSmoothTransition;
  float normalFacingExponent;
} cloudmaterial;

typedef struct { 
  struct {
    int __id;
    vec3 position;
    vec2 size;
    rgb color;
    float opacity;
    float cutoff;
    float horizontalHeading;
    bool horizontal;
    bool flipHorizontal;
    bool flipVertical;
    bool customOrientation;
    bool noTilt;
    bool flipHorizontalShading;
    vec3 up;
    vec3 side;
  };
  
  vec2 noiseOffset;
  float shadowOpacity;
  bool useNoise;
  bool occludeGodrays;
  bool useCustomLightColor;
  bool useCustomLightDirection;
  uint8_t version;
  bool passedFrustumTest;

  cloudmaterial* __material;
  rgb extraDownlit;
  rgb customLightColor;
  vec3 customLightDirection;

  vec2 procMap;
  vec2 procScale;
  vec2 procNormalScale;
  float procShapeShifting;
  float procSharpnessMult;

  vec2 texStart;
  vec2 texSize;
  float orderBy;
  float fogMultiplier;
  float extraFidelity;
  float receiveShadowsOpacityMult;
  float normalYExponent;
  float topFogBoost;
} cloud;

typedef struct {
  float _pad;
  float perlinFrequency;
  int perlinOctaves;
  float worleyFrequency;
  float shapeMult;
  float shapeExp;
  float shape0Mip;
  float shape0Contribution;
  float shape1Mip;
  float shape1Contribution;
  float shape2Mip;
  float shape2Contribution;
} cloud_map_settings;
]]

ffi.metatype('cloudmaterial', { __index = {} })

---Describes details of cloud shading.
---@class ac.SkyCloudMaterial
---@field ambientColor rgb "Ambient lighting, final contribution is adjusted by normal (100% with normal facing up, also controlled by ambientConcentration). Final ambient lighting can also use scene ambient lighting as a multiplier if useSceneAmbient is set to true."
---@field frontlitMultiplier number "Multiplier for regular “diffuse” lighting."
---@field frontlitDiffuseConcentration number "With 0, “diffuse” lighting is at 100% no matter where cloud is facing."
---@field backlitExponent number "Exponent for `dot(-eyesToCloud, lightDirection)` bit of backlit calculation."
---@field backlitOpacityExponent number "Increase to make semi-transparent areas less backlit (less effect on more transparent areas)."
---@field backlitOpacityMultiplier number "Increase to make semi-transparent areas less backlit."
---@field backlitMultiplier number "Backlit multiplier."
---@field specularPower number "Intensity of specular lighting."
---@field specularExponent number "Exponent of specular lighting computation, increase for smaller specular areas."
---@field fogMultiplier number "Fog multiplier. Default value: 1."
---@field baseColor rgb "Final shading color is baseColor * cloud.color * lightColor (either from cloud.customLightColor if cloud.useCustomLightColor is set, or scene light color)."
---@field extraDownlit rgb "Additional lighting applied to bottoms of a clouds. Final downlit is extraDownlit + cloud.extraDownlit."
---@field lightSaturation number "Adjusts lightColor saturation (where lightColor is either cloud.customLightColor if cloud.useCustomLightColor is set, or scene light color). Default value: 1."
---@field ambientConcentration number "Affects how much normal contributes as ambientColor multiplier, with 0 ambientColor is 100% effective no matter the normal. Default value: 0.\n\nOnly affects v2 clouds."
---@field contourExponent number "Increase to make contours thinner. Default value: 1.\n\nOnly affects v2 clouds."
---@field contourIntensity number "Intensity of contours shading effect. Default value: 0.\n\nOnly affects v2 clouds."
---@field useSceneAmbient boolean "If set to true, final ambientColor will be multiplied by scene ambient color before rendering. Default value: `true`.\n\nOnly affects v2 clouds."
---@field receiveShadowsOpacity number "Opacity of shadows being cast onto clouds with this material (shadows from other clouds). Default value: 0.\n\nOnly affects v2 clouds."
---@field alphaSmoothTransition number "With 0 alpha is applied as-is from textures, with 1 smoothstep function is applied to it, could be something in-between as well. Helps to make clouds look smoother. Default value: 0.\n\nOnly affects v2 clouds."
---@field normalFacingExponent number "Alters how normal of a cloud is calculated, increasing it might help to make cloud look rounder and nicer. Default value is kept for compatibility. Default value: 0.5.\n\nOnly affects v2 clouds."
---@constructor fun(): ac.SkyCloudMaterial
function ac.SkyCloudMaterial()
  return ffi.gc(ffi.C.lj_cloudmaterial_new__impl(), ffi.C.lj_cloudmaterial_gc__impl) 
end

-- ac.SkyCloud, keeps .material reference in Lua table to save it from GC
local __cloudMaterialKeepAlive = {}
local __cloudExtraData = {}
ffi.metatype('cloud', {
  __index = function(self, key) 
    if key == 'setTexture' then return ffi.C.lj_cloud_set_texture__impl end
    if key == 'getTextureState' then return ffi.C.lj_cloud_get_texture_state__impl end
    if key == 'setNoiseTexture' then return ffi.C.lj_cloud_set_noise_texture__impl end
    if key == 'getNoiseTextureState' then return ffi.C.lj_cloud_get_noise_texture_state__impl end
    if key == 'material' then return self.__material end
    if key == 'extras' then 
      if __cloudExtraData[self.__id] == nil then __cloudExtraData[self.__id] = {} end
      return __cloudExtraData[self.__id] 
    end
    error('Cloud has no member called “' .. key .. '”', 2)
  end,
  __newindex = function(self, key, value) 
    if key == 'material' then 
      if value == nil then error('Cloud material cannot be nil', 2) end
      self.__material = value
      __cloudMaterialKeepAlive[self.__id] = value
      return
    end
    error('Cloud has no member called “' .. key .. '”', 2)
  end,
})

function ac.SkyCloud() 
  local created = ffi.C.lj_cloud_new__impl()
  created.material = ac.SkyCloudMaterial()
  return ffi.gc(created, function (self)
    table.remove(__cloudMaterialKeepAlive, self.__id)
    table.remove(__cloudExtraData, self.__id)
    ffi.C.lj_cloud_gc__impl(self)
  end)
end

function ac.SkyCloudV2()
  local ret = ac.SkyCloud()
  ret.version = 2
  return ret
end

---Clouds v2 use a special 3D noise texture to change shape live. This structure describes parameters for generating said texture. Note:
---texture is quite heavy and takes some time to generate, so don’t change those settings live.
---@class ac.SkyCloudMapParams
---@field perlinFrequency number "Frequency of perlin noise."
---@field perlinOctaves integer "Perlin noise octaves."
---@field worleyFrequency number "Frequiency of worley noise."
---@field shapeMult number "Multiplier for shape estimation intensity."
---@field shapeExp number "Exponent for shape estimation intensity."
---@field shape0Mip number "MIP level used to estimate shape in first layer."
---@field shape0Contribution number "Contribution of the first shape layer."
---@field shape1Mip number "MIP level used to estimate shape in second layer."
---@field shape1Contribution number "Contribution of the second shape layer."
---@field shape2Mip number "MIP level used to estimate shape in third layer."
---@field shape2Contribution number "Contribution of the third shape layer."
ac.SkyCloudMapParams = ffi.metatype('cloud_map_settings', {
  __index = {
    ---@return ac.SkyCloudMapParams
    new = function()
      local ret = ac.SkyCloudMapParams()
      ret.perlinFrequency = 4.0
      ret.perlinOctaves = 7
      ret.worleyFrequency = 4.0
      ret.shapeMult = 20.0
      ret.shapeExp = 0.5
      ret.shape0Mip = 0.0
      ret.shape0Contribution = 0.3
      ret.shape1Mip = 2.2
      ret.shape1Contribution = 0.5
      ret.shape2Mip = 4.5
      ret.shape2Contribution = 1.0
      return ret
    end
  }
})
