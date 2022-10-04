__source 'lua/lua_audio_event.cpp'

ffi.cdef [[ 
typedef struct {
  void* host_;
  void* nativeEvent_;
  void* nativeChannel_;
  mat4x4 transform_;
  vec3 velocity_;
  float volume;
  float pitch;
  float cameraInteriorMultiplier;
  float cameraExteriorMultiplier;
  float cameraTrackMultiplier;
  bool inAutoLoopMode;
  bool reverbResponse_;
} audioevent;
]]

local __audioEventKeepAlive = {}

ac.AudioEvent = setmetatable({
  fromFile = function(params, reverbResponse)
    local created = ffi.C.lj_audioevent_newfile(__util.json(params), reverbResponse and true or false)
    __audioEventKeepAlive[#__audioEventKeepAlive + 1] = created
    return ffi.gc(created, ffi.C.lj_audioevent_gc)
  end
}, {
  __call = function(_, eventName, reverbResponse)
    local created = ffi.C.lj_audioevent_new(tostring(eventName), reverbResponse and true or false)
    __audioEventKeepAlive[#__audioEventKeepAlive + 1] = created
    return ffi.gc(created, ffi.C.lj_audioevent_gc)
  end
})

---Audio event is a audio emitter which uses a certain event from one of loaded FMOD soundbanks.
---@class ac.AudioEvent
---@field volume number @Audio volume, from 0 to 1 (can go above too, but clipping might occur). Default value: 1.
---@field pitch number @Audio pitch. Default value: 1.
---@field cameraInteriorMultiplier number @Multiplier for audio volume with interior camera. Default value: 0.25.
---@field cameraExteriorMultiplier number @Multiplier for audio volume with exterior (chase or free, for example) camera. Default value: 1.
---@field cameraTrackMultiplier number @Multiplier for audio volume with track camera (those replay cameras with low FOV). Default value: 1.
---@field inAutoLoopMode number @If set to `true`, aduio event would automatically start when in range of camera and volume is above 0. Default value: `false`.
---@explicit-constructor ac.AudioEvent
ffi.metatype('audioevent', { __index = {
  ---Sets audio event orientation.
  ---@param pos vec3 @Position. If you’re working on a car script, position is relative to car position.
  ---@param dir vec3|nil @Direction. If missing, forwards vector is used.
  ---@param up vec3|nil @Vector directed up for full 3D orientation.
  ---@param vel vec3|nil @Velocity of audio source. If missing, sound is stationary. If you’re working on a car script, velocity is relative to car velocity.
  setPosition = function (s, pos, dir, up, vel)  ffi.C.lj_audioevent_set_pos(s, __util.ensure_vec3(pos), __util.ensure_vec3_nil(dir), __util.ensure_vec3_nil(up), __util.ensure_vec3(vel)) end,

  ---Deprecated, now all events are alive until `:dispose()` is called.
  ---@deprecated
  keepAlive = function (s) end,

  ---Set value of an audio event parameter.
  ---@param name string
  ---@param value number
  setParam = function (s, name, value) ffi.C.lj_audioevent_set_param(s, __util.str(name), tonumber(value) or 0) end,

  ---Returns `true` if event is loaded successfully. If event does not load, make sure soundbank is loaded first, and that event name is correct.
  ---@return boolean
  isValid = function (s) return s.host_ ~= nil and (s.nativeEvent_ ~= nil or s.nativeChannel_ ~= nil) end,

  ---Returns `true` if audio event is playing.
  ---@return boolean
  isPlaying = ffi.C.lj_audioevent_is_playing,

  ---Returns `true` if audio event is paused.
  ---@return boolean
  isPaused = ffi.C.lj_audioevent_is_paused,

  ---Return `true` if audio event is within hearing range of current listener. Could be a good way to pause some expensive processing
  ---for distant audio events. Although in general comparing distance with a threshold on Lua side with vectors might be faster (without
  ---going Lua→CSP→FMOD and back).
  ---@return boolean
  isWithinRange = ffi.C.lj_audioevent_is_within_range,

  resume = ffi.C.lj_audioevent_resume,

  ---If condition is `true`, start an audio event if it’s stopped, resume it if it’s paused. If condition is false, stop audio event.
  ---@param condition boolean
  resumeIf = function (s, condition) return ffi.C.lj_audioevent_resume_if(s, condition) end,

  ---Stop audio event.
  stop = ffi.C.lj_audioevent_stop,

  ---Start audio event.
  start = ffi.C.lj_audioevent_start,

  ---If you need to move audio event often, accessing its matrix directly might be the best way. But you have to be extra careful in
  ---making sure matrix is always normalized (vectors `side`, `up` and `look` should be othrogonal with lengths of 1), otherwise
  ---audio might sound strange, with rapid changes in volume.
  ---@return mat4x4
  getTransformationRaw = function (s) return s.transform_ end,

  ---Stop and remove audio event.
  dispose = function (s) table.removeItem(__audioEventKeepAlive, s) ffi.C.lj_audioevent_dispose(s) end,
}})
