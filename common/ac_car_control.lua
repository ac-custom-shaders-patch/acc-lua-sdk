__source 'lua/api_car_control.cpp'
__source 'extensions/smart_mirror/ac_ext_smart_mirror.cpp'
__allow 'carc'

ffi.cdef [[ 
typedef struct {
  vec2 rotation;
  float fov;
  float aspectMultiplier;
  int flip;
  bool isMonitor;
  bool useMonitorShader;
  int role;
  vec2 monitorShaderScale;
  float monitorShaderSkew;
  float monitorShaderType;
} realmirrorparams;
]]

---Stores Real Mirror parameters for a real view mirror.
---@class ac.RealMirrorParams
---@field rotation vec2 @Mirror tilt, X for horizontal and Y for vertical.
---@field fov number @Field of view angle in degrees, automatically guessed value: 10.
---@field aspectMultiplier number @Aspect ratio multiplier.
---@field flip ac.MirrorPieceFlip @Optional texture mapping flip parameter.
---@field isMonitor boolean @Monitor mirrors don’t reflect car they’re in.
---@field useMonitorShader boolean @Monitor shader has brightness that works slightly differently, a bit of color distortion at steep view angles (depends on monitor type) and a pixel grid if viewed really close.
---@field role ac.MirrorPieceRole @Role of mirror piece. Used by adaptive virtual mirrors.
---@field monitorShaderScale vec2 @Scale of pixels grid for monitor shader. Automatically guessed value: `vec2(600, 150)`. Think of it as display resolution.
---@field monitorShaderSkew number @Skew of pixels grid to align pixels with tilted monitors.
---@field monitorShaderType ac.MirrorMonitorType @Type of monitor shader. By default guessed based on manufacturing year.
ac.RealMirrorParams = ffi.metatype('realmirrorparams', { __index = {
} })

---Returns set of mirror settings for a given Real Mirror mirror (for car scripts, associated car, for apps and tools — player’s car).
---@param mirrorIndex integer @0-based mirror index (leftmost mirror is 0, the first one to right of it is 1 and so on)
---@return ac.RealMirrorParams
function ac.getRealMirrorParams(mirrorIndex)
  local r = ffi.C.lj_getRealMirrorParams_inner__carc(mirrorIndex)
  if r.fov == -1 then return nil end
  return r
end