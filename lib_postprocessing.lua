__source 'extensions/weather_fx/ac_ext_weather_fx__lua_pp.h'
__allow 'impl'

ffi.cdef [[ 
typedef struct {
  bool active;
  float3 center;
  float width, depth, height;
} _pp_particle_set;

typedef struct {
  void* __0;
  void* __1;
  void* __2;
  float dt;
  float hue;
  float saturation;
  float brightness;
  float contrast;
  float sepia;
  float colorTemperature;
  float whiteBalance;
  int fixedWidth;
  int __aperture_reslt_blur_modify;
  int __heat_particle_enabled;
  int __heat_particle_active;
  float __heat_particle_radius;
  float __heat_particle_shimmer;
  float __heat_particle_coord;
  float __heat_particle_fractal_octaves;
  rgb __heat_particle_color;
  int __heat_particle_max_number_per_set;
  int __heat_particle_sets_number;
  float __heat_particle_min_life;
  float __heat_particle_life_mult;
  float __heat_particle_intensity_mult;
  float __heat_particle_min_intensity;
  float __heat_particle_intensity_velocity_mult;
  float __heat_particle_intensity_min_velocity;
  float __heat_particle_position_velocity[3];
  float filmicContrast; // __heat_particle_radius_velocity_mult
  _pp_particle_set __heat_particle_sets[29];
  bool customTonemappingFunctionCode; // __heat_particle_sets_30_active
  vec2 __heat_particle_sets_center;
  vec2 autoExposureAreaSize;
  vec2 autoExposureAreaOffset;
  float cameraNearPlane;
  float cameraFarPlane;
  float cameraVerticalFOVRad;
  mat4x4 cameraMatrix;
  mat4x4 viewMatrix;
  int tonemapUseHDRSpace;
  float tonemapExposure;
  float tonemapGamma;
  int tonemapFunction;
  float tonemapViewportScaleWidth;
  float tonemapViewportScaleHeight;
  float tonemapViewportOffsetX;
  float tonemapViewportOffsetY;
  float tonemapMappingFactor;
  bool autoExposureEnabled; bool __pad1[3];
  float autoExposureDelay;
  float autoExposureMin;
  float autoExposureMax;
  float autoExposureTarget;
  bool autoExposureInfluencedByGlare; bool __pad2[3];
  float vignetteStrength;
  float vignetteFOVDependence;
  bool chromaticAberrationEnabled; bool __pad3[3];
  bool chromaticAberrationActive; bool __pad4[3];
  int chromaticAberrationSamples;
  vec2 chromaticAberrationLateralDisplacement;
  vec2 chromaticAberrationUniformDisplacement;
  float diaphragmRotateScale;
  float diaphragmRotateOffsetRad;
  int diaphragmRotationType;
  bool feedbackEnabled; bool __pad5[3];
  float feedbackAspectRatio;
  float feedbackWeight;
  float feedbackCurrentWeight;
  float feedbackTimeInSeconds;
  int __airydisk_enabled;
  float __airydisk_wavelength;
  int __airydisk_dispersion;
  bool glareEnabled; bool __pad6[3];
  bool glareAnamorphic; bool __pad7[3];
  int glareShape;
  int glarePrecision;
  int glareQuality;
  int glareBrightPass;
  bool glareUseCustomShape; bool __pad8[3];
  bool glareAfterImage; bool __pad9[3];
  bool glareGhost; bool __pad10[3];
  bool glareGhostActive; bool __pad11[3];
  float glareGhostConcentricDistortion;
  float glareLuminance;
  float glareBlur;
  float glareThreshold;
  float glareBloomFilterThreshold;
  float glareBloomGaussianRadiusScale;
  float glareBloomLuminanceGamma;
  int glareBloomLevels;
  float glareGenerationRangeScale;
  float glareStarLengthFOVDependence;
  float glareStarSoftness;
  float glareStarFilterThreshold;
  float glareFOVDependence;
  float glareShapeLuminance;
  float glareShapeBloomLuminance;
  float glareShapeBloomDispersion;
  int glareShapeBloomDispersionBaseLevel;
  float glareShapeGhostLuminance;
  float glareShapeGhostHaloLuminance;
  float glareShapeGhostDistortion;
  bool glareShapeGhostSharpeness;
  float glareShapeStarLuminance;
  int glareShapeStarStreaks;
  float glareShapeStarLength;
  float glareShapeStarSecondaryLength;
  bool glareShapeStarRotation; bool __pad12[3];
  float glareShapeStarInclinationAngle;
  float glareShapeStarDispersion;
  bool glareShapeStarForceDispersion; bool __pad13[3];
  float glareShapeAfterimageLuminance;
  float glareShapeAfterimageLength;
  bool dofEnabled; bool __pad14[3];
  bool dofActive; bool __pad15[3];
  int dofQuality;
  float dofFocusDistance;
  float dofApertureFNumber;
  float dofImageSensorHeight;
  float dofVerticalFOVBaseRad;
  float dofAdaptiveApertureFactor;
  int dofApertureParameter;
  int dofApertureType;
  int dofApertureFrontLevels;
  int dofApertureBackLevels;
  float dofBackgroundMaskThreshold;
  int dofEdgeQuality;
  bool godraysEnabled; bool __pad16[3];
  bool godraysInCameraFustrum; bool __pad17[3];
  vec2 godraysOrigin;
  float godraysDiffractionRing;
  float godraysDiffractionRingAttenuation;
  float godraysDiffractionRadius;
  float godraysDiffractionRingSpectrumOrder;
  rgbm godraysDiffractionRingOuterColor;
  bool godraysUseSunLightColor;
  rgbm godraysColor;
  float godraysLength;
  float godraysGlareRatio;
  float godraysAngleAttenuation;
  float godraysNoiseMask;
  float godraysNoiseFrequency;
  float godraysDepthMaskThreshold;
  bool lensDistortionEnabled; bool __pad18[3];
  float lensDistortionRoundness;
  float lensDistortionSmoothness;
  bool __antialiasEnabled; bool __pad19[3];
  float __antialiasStartDistance;
  float __antialiasEndDistance;
} pp_params_data;
]]

---Structure containing postprocessing parameters to be applied. Could be used to sync settings with custom postprocessing or alter something live.
---@class ac.PostProcessingParameters
---@field dt number
---@field hue number
---@field saturation number
---@field brightness number
---@field contrast number
---@field sepia number
---@field colorTemperature number
---@field whiteBalance number
---@field fixedWidth integer
---@field cameraNearPlane number
---@field cameraFarPlane number
---@field cameraVerticalFOVRad number
---@field cameraMatrix mat4x4
---@field viewMatrix mat4x4
---@field tonemapUseHDRSpace integer
---@field tonemapExposure number
---@field tonemapGamma number
---@field tonemapFunction integer
---@field tonemapViewportScaleWidth number
---@field tonemapViewportScaleHeight number
---@field tonemapViewportOffsetX number
---@field tonemapViewportOffsetY number
---@field tonemapMappingFactor number
---@field autoExposureEnabled boolean
---@field autoExposureDelay number
---@field autoExposureMin number
---@field autoExposureMax number
---@field autoExposureTarget number
---@field autoExposureInfluencedByGlare boolean
---@field autoExposureAreaSize vec2
---@field autoExposureAreaOffset vec2
---@field vignetteStrength number
---@field vignetteFOVDependence number
---@field chromaticAberrationEnabled boolean
---@field chromaticAberrationActive boolean
---@field chromaticAberrationSamples integer
---@field chromaticAberrationLateralDisplacement vec2
---@field chromaticAberrationUniformDisplacement vec2
---@field diaphragmRotateScale number
---@field diaphragmRotateOffsetRad number
---@field diaphragmRotationType integer
---@field feedbackEnabled boolean
---@field feedbackAspectRatio number
---@field feedbackWeight number
---@field feedbackCurrentWeight number
---@field feedbackTimeInSeconds number
---@field glareEnabled boolean
---@field glareAnamorphic boolean
---@field glareShape integer
---@field glarePrecision integer
---@field glareQuality integer
---@field glareBrightPass integer
---@field glareUseCustomShape boolean
---@field glareAfterImage boolean
---@field glareGhost boolean
---@field glareGhostActive boolean
---@field glareGhostConcentricDistortion number
---@field glareLuminance number
---@field glareBlur number
---@field glareThreshold number
---@field glareBloomFilterThreshold number
---@field glareBloomGaussianRadiusScale number
---@field glareBloomLuminanceGamma number
---@field glareBloomLevels integer
---@field glareGenerationRangeScale number
---@field glareStarLengthFOVDependence number
---@field glareStarSoftness number
---@field glareStarFilterThreshold number
---@field glareFOVDependence number
---@field glareShapeLuminance number
---@field glareShapeBloomLuminance number
---@field glareShapeBloomDispersion number
---@field glareShapeBloomDispersionBaseLevel integer
---@field glareShapeGhostLuminance number
---@field glareShapeGhostHaloLuminance number
---@field glareShapeGhostDistortion number
---@field glareShapeGhostSharpeness boolean
---@field glareShapeStarLuminance number
---@field glareShapeStarStreaks integer
---@field glareShapeStarLength number
---@field glareShapeStarSecondaryLength number
---@field glareShapeStarRotation boolean
---@field glareShapeStarInclinationAngle number
---@field glareShapeStarDispersion number
---@field glareShapeStarForceDispersion boolean
---@field glareShapeAfterimageLuminance number
---@field glareShapeAfterimageLength number
---@field dofEnabled boolean
---@field dofActive boolean
---@field dofQuality integer
---@field dofFocusDistance number
---@field dofApertureFNumber number
---@field dofImageSensorHeight number
---@field dofVerticalFOVBaseRad number
---@field dofAdaptiveApertureFactor number
---@field dofApertureParameter integer
---@field dofApertureType integer
---@field dofApertureFrontLevels integer
---@field dofApertureBackLevels integer
---@field dofBackgroundMaskThreshold number
---@field dofEdgeQuality integer
---@field godraysEnabled boolean
---@field godraysInCameraFustrum boolean
---@field godraysOrigin vec2
---@field godraysDiffractionRing number
---@field godraysDiffractionRingAttenuation number
---@field godraysDiffractionRadius number
---@field godraysDiffractionRingSpectrumOrder number
---@field godraysDiffractionRingOuterColor rgbm
---@field godraysUseSunLightColor boolean
---@field godraysColor rgbm
---@field godraysLength number
---@field godraysGlareRatio number
---@field godraysAngleAttenuation number
---@field godraysNoiseMask number
---@field godraysNoiseFrequency number
---@field godraysDepthMaskThreshold number
---@field lensDistortionEnabled boolean
---@field lensDistortionRoundness number
---@field lensDistortionSmoothness number
---@field filmicContrast number
---@field customTonemappingFunctionCode boolean @If `true`, current YEBIS filter has a custom tonemapping implementation. Use `ac.getCustomTonemappingFunctionCode()` to get it.
---@cpptype pp_params_data
ffi.metatype('pp_params_data', { __index = {} })

local rtSize = vec2()

__definitions()

--[[? if (ctx.ldoc) out(]]

---Get custom tonemapping function code from currently selected PP filter, or `nil` if it’s not set.
---@return string?
function ac.getCustomTonemappingFunctionCode() end

--[[) ?]]

return function(callback)
  return __util.disposable(ffi.C.lj_onPostProcessing_inner__impl(__util.setCallback(function (exposure, mainPass, updateExposure, sizeX, sizeY)
    rtSize.x, rtSize.y = sizeX, sizeY
    local ret = callback(ffi.C.lj_getPostProcessing_inner__impl(), exposure, mainPass, updateExposure, rtSize)
    if type(ret) == 'boolean' then
      return ret
    elseif ret then
      ffi.C.lj_setPostProcessingInput_inner__impl(tostring(ret))
    end
  end)))
end
