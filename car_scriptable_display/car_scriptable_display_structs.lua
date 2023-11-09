__source 'extensions/car_instruments/rendering_camera.cpp'
__source 'extensions/car_instruments/texture_preprocessing.cpp'

ffi.cdef [[ 
typedef struct {
  vec3 position;
  vec3 look;
  vec3 up;
  float refreshRate;
  float fov;
  float aspectRatio;
  float clipNear;
  float clipFar;
  bool interiorOnly;
  bool includeCar;
  bool includeDriver;
  bool includeSky;
  bool includeTransparent;
  bool withLighting;
  bool active;
} state_car_rendering_camera;
]]

---Holds description of a rendering camera available for both reading and writing.
---@class ac.StateCarRenderingCamera
---@field active boolean @Altering this value is the same as calling `ac.setRenderingCameraActive()`, but faster if you only access camera state once and cache the reference.
---@field position vec3 @Position relative to car or parent node.
---@field look vec3 @Direction relative to car or parent node.
---@field up vec3 @Up orientation relative to car or parent node.
---@field refreshRate number @Number of frames per second.
---@field fov number @FOV in degrees.
---@field aspectRatio number
---@field clipNear number
---@field clipFar number
---@field interiorOnly boolean
---@field includeCar boolean
---@field includeDriver boolean
---@field includeSky boolean
---@field includeTransparent boolean
---@field withLighting boolean
ffi.metatype('state_car_rendering_camera', { __index = {} })

ffi.cdef [[ 
typedef struct {
  float exposure;
  float brightness;
  float saturation;
  float gamma;
} state_car_texture_preprocessing;
]]

---Holds description of a texture preprocessing stage available for both reading and writing.
---@class ac.StateCarTexturePreprocessing
---@field exposure number
---@field brightness number
---@field saturation number
---@field gamma number
ffi.metatype('state_car_texture_preprocessing', { __index = {} })

ffi.cdef [[ 
typedef struct {
  rgb color;
  float intensity;

  rgb lineColor;
  float lineIntensity;

  rgb offColor;
  float offIntensity;

  vec3 position;
  vec3 direction;
  vec3 up;
  vec3 linePos;

  float specularMultiplier;
  vec3 offPosition;

  float spotEdgeSharpness;
  float offRangeMultiplier;
  float spot;
  float secondSpot;

  vec3 spotEdgeOffset;
  float secondSpotTrimStart;
  float secondSpotRange;
  float secondSpotIntensity;

  float _p00__;
  float _p01__;
  float _p02__;
  float _p03__;
  float spotSharpness;
  float _p05__;

  float _p10__;
  float _p11__;
  float _p12__;
  float _p13__;
  float secondSpotSharpness;
  float _p15__;

  float singleFrequency;
  float range;
  float rangeGradientOffset;
  bool active;
} state_car_light;
]]

---Holds description of a texture preprocessing stage available for both reading and writing.
---@class ac.StateCarLight
---@field active boolean @Disabling unused lights is always a good idea.
---@field color rgb
---@field intensity number
---@field lineColor rgb
---@field lineIntensity number
---@field offColor rgb
---@field offIntensity number
---@field position vec3
---@field direction vec3
---@field up vec3
---@field linePos vec3
---@field specularMultiplier number
---@field offPosition vec3
---@field spotEdgeSharpness number
---@field offRangeMultiplier number
---@field spot number
---@field spotSharpness number
---@field spotEdgeOffset vec3 @Affects headlights and brake lights.
---@field secondSpot number @Affects headlights and brake lights.
---@field secondSpotSharpness number @Affects headlights and brake lights.
---@field secondSpotTrimStart number @Affects headlights and brake lights.
---@field secondSpotRange number @Affects headlights and brake lights.
---@field secondSpotIntensity number @Affects headlights and brake lights.
---@field singleFrequency number
---@field range number
---@field rangeGradientOffset number
ffi.metatype('state_car_light', { __index = {} })
