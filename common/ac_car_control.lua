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
  float monitorBrightness;
  vec3 monitorCameraPosition;
  vec3 monitorCameraLook;
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
---@field monitorBrightness number @Monitor brightness, 1 for regular brightness.
ac.RealMirrorParams = ffi.metatype('realmirrorparams', { __index = {
  ---@return ac.RealMirrorParams
  clone = function(s)
    return ac.RealMirrorParams(s)
  end
} })

---Returns set of mirror settings for a given Real Mirror mirror (for car scripts, associated car, for apps and tools — player’s car).
---@param mirrorIndex integer @0-based mirror index (leftmost mirror is 0, the first one to right of it is 1 and so on)
---@return ac.RealMirrorParams
function ac.getRealMirrorParams(mirrorIndex)
  local r = ffi.C.lj_getRealMirrorParams_inner__carc(mirrorIndex)
  if r.fov == -1 then return nil end
  return r
end

---Tweak car audio events live: alter volume, pitch, fading distance, position, transform parameters (same as with `[AUDIO_…]` sections
---in car config file). Additionally, it allows to control extra FMOD event parameters in case you need to add further fidelity. Most functions,
---apart from `ac.CarAudioTweak.parameterTransform()`, are quick enough that you can call them every frame with no issues.
---
---Note: if you’re making something other than a car script, please be careful with these functions, as it might override values configured 
---by original car config or a car script. If conflicts will become an issue later on some workaround will be added (possibly a system 
---allowing car configs or scripts to block other scripts interfering with its audio configuration).
ac.CarAudioTweak = {}

---Set volume multiplier. Overrides `[AUDIO_VOLUME]` value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param value number @New value from 0 to 1 (100%), can go above 1 as well.
function ac.CarAudioTweak.setVolume(eventID, value)
  ffi.C.lj_setCarAudioTweak_n__carc(tonumber(eventID) or 0, 0, tonumber(value) or 0)
end

---Get current volume multiplier set by `[AUDIO_VOLUME]` or a Lua script.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@return number @Returns `math.NaN` if there is no such event.
function ac.CarAudioTweak.getVolume(eventID)
  return ffi.C.lj_getCarAudioTweak_n__carc(tonumber(eventID) or 0, 0)
end

---Set pitch multiplier. Overrides `[AUDIO_PITCH]` value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param value number @New value from 0 to 1 (100%), can go above 1 as well.
function ac.CarAudioTweak.setPitch(eventID, value)
  ffi.C.lj_setCarAudioTweak_n__carc(tonumber(eventID) or 0, 1, tonumber(value) or 0)
end

---Get current pitch multiplier set by `[AUDIO_PITCH]` or a Lua script.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@return number @Returns `math.NaN` if there is no such event.
function ac.CarAudioTweak.getPitch(eventID)
  return ffi.C.lj_getCarAudioTweak_n__carc(tonumber(eventID) or 0, 1)
end

---Set attenuation start distance (at this distance volume will start decreasing). Overrides `[AUDIO_3D_DISTANCE] …_MIN`
---value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param value number @New value in meters, or `-1` to reset to default FMOD value.
function ac.CarAudioTweak.setDistanceMin(eventID, value)
  ffi.C.lj_setCarAudioTweak_n__carc(tonumber(eventID) or 0, 2, tonumber(value) or 0)
end

---Get current attenuation start distance set by audio event properties, `[AUDIO_3D_DISTANCE]` or a Lua script.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@return number @Returns `math.NaN` if there is no such event, or `-1` if value is the default one from FMOD.
function ac.CarAudioTweak.getDistanceMin(eventID)
  return ffi.C.lj_getCarAudioTweak_n__carc(tonumber(eventID) or 0, 2)
end

---Set attenuation end distance (at this distance volume will stops decreasing, but sound might still be heard, 
---depending on FMOD audio event configuration). Overrides `[AUDIO_3D_DISTANCE] …_MAX` value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param value number @New value in meters, or `-1` to reset to default FMOD value.
function ac.CarAudioTweak.setDistanceMax(eventID, value)
  ffi.C.lj_setCarAudioTweak_n__carc(tonumber(eventID) or 0, 3, tonumber(value) or 0)
end

---Get current attenuation end distance set by audio event properties, `[AUDIO_3D_DISTANCE]` or a Lua script.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@return number @Returns `math.NaN` if there is no such event, or `-1` if value is the default one from FMOD.
function ac.CarAudioTweak.getDistanceMax(eventID)
  return ffi.C.lj_getCarAudioTweak_n__carc(tonumber(eventID) or 0, 3)
end

---Set audio transformation (position and rotation) relative to car. Overrides `[AUDIO_TRANSFORM]` value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param value mat4x4 @Transformation matrix (make sure it’s normalized).
function ac.CarAudioTweak.setTransform(eventID, value)
  ffi.C.lj_setCarAudioTweak_m__carc(tonumber(eventID) or 0, 4, __util.ensure_mat4x4(value))
end

---Set LUT used for converting parameter values computed by AC into something else. Overrides `[AUDIO_PARAMETER_TRANSFORM]` value from car config.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param key string @Name of the parameter
---@param value ac.Lut @LUT mapping original input values into custom output values.
function ac.CarAudioTweak.setParameterTransform(eventID, key, value)
  ffi.C.lj_setCarAudioTweak_l__carc(tonumber(eventID) or 0, 5, tostring(key), ffi.istype('numlut', value) and value or error('ac.Lut is required', 2))
end

---Set value of an FMOD audio event parameter. Feel free to call it every frame if you want to update it live.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param key string @Name of the parameter
---@param value number @New value in a range expected by FMOD audio event.
---@param override boolean? @Set to `true` to override a value AC might set, can be useful to tweak something like `rpms` of engine audio.
function ac.CarAudioTweak.setParameter(eventID, key, value, override)
  ffi.C.lj_setCarAudioTweak_p__carc(tonumber(eventID) or 0, override and 8 or 6, tostring(key), tonumber(value) or 0)
end

---Set value of a custom DSP for the audio event. If DSP is missing, create and add it at the front.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param dsp string @DSP name.
---@param key integer|'enable'|'disable'|'remove'|'wetDry' @Index of DSP parameter, or an action. If `wetDry` is specified, value should be a table with values `prewet`, `postwet` and `dry`.
---@param value number|table|nil @Value.
function ac.CarAudioTweak.setDSP(eventID, dsp, key, value)
  return __util.native('lj_setCarAudioTweak_d__carc', eventID, dsp, key, value)
end

---Get value of an FMOD audio event parameter.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param key string @Name of the parameter
---@return number @Returns `math.NaN` if there is no such event or parameter.
function ac.CarAudioTweak.getParameter(eventID, key)
  return ffi.C.lj_getCarAudioTweak_p__carc(tonumber(eventID) or 0, 6, tostring(key))
end

---Replaces entire audio event with a different one.
---@param eventID ac.CarAudioEventID @ID of a target event.
---@param newEventKey string @Key for the new audio event, like `'/cars/accr_mclaren_f1/engine_ext'`.
function ac.CarAudioTweak.replaceAudioEvent(eventID, newEventKey)
  ffi.C.lj_setCarAudioTweak_p__carc(tonumber(eventID) or 0, 7, tostring(newEventKey), 0)
end

ffi.cdef [[ 
typedef struct {
  mat4x4 transform;
  float fov;
  float exposure;
  bool externalSound;
} carcameradef;
]]

---Stores parameters for a car camera (enabled with F6).
---@class ac.CarCameraParams
---@field transform mat4x4 @Transformation relative to car model. Note: due to some techical reasons direction `.look` is facing backwards.
---@field fov number @Field of view angle in degrees, automatically guessed value: 10.
---@field exposure number @Exposure.
---@field externalSound boolean @Should internal or external audio be used.
ffi.metatype('carcameradef', { __index = {} })

---@param cameraIndex integer @0-based camera index (use `car.carCamerasCount` to get the number of cameras).
---@return ac.CarCameraParams? @Returns `nil` if there is no camera with such index.
function ac.accessCarCamera(cameraIndex)
  local r = ffi.C.lj_accessCarCamera_inner__carc(tonumber(cameraIndex) or 0)
	return r ~= nil and r or nil
end


