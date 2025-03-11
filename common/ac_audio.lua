__source 'lua/lua_audio_event.cpp'

require './ac_audio_enums'

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
  int channelID_;
  bool inAutoLoopMode;
  bool reverbResponse_;
} audioevent;
]]

local __audioEventKeepAlive = {}

ac.AudioEvent = setmetatable({
  fromFile = function(params, reverbResponse)
    if type(params) ~= 'table' then params = {} end
    local created = ffi.C.lj_audioevent_newfile(__util.json(params), reverbResponse and true or false, params.group and params.group.channelID_ or 0)
    __audioEventKeepAlive[#__audioEventKeepAlive + 1] = created
    return ffi.gc(created, ffi.C.lj_audioevent_gc)
  end,
  group = function(params, reverbResponse)
    if type(params) ~= 'table' then params = {} end
    local created = ffi.C.lj_audioevent_newfile(__util.json(table.assign({['$group'] = true}, params)), reverbResponse and true or false, params.group and params.group.channelID_ or 0)
    __audioEventKeepAlive[#__audioEventKeepAlive + 1] = created
    return ffi.gc(created, ffi.C.lj_audioevent_gc)
  end
}, {
  __call = function(_, eventName, reverbResponse, useOcclusion)
    local created = ffi.C.lj_audioevent_new(tostring(eventName), reverbResponse and true or false, useOcclusion and true or false)
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
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setPosition = function (s, pos, dir, up, vel)
    ffi.C.lj_audioevent_set_pos(s, __util.ensure_vec3(pos), __util.ensure_vec3_nil(dir), __util.ensure_vec3_nil(up), __util.ensure_vec3(vel))
    return s
  end,

  --[[? if (!ctx.flags.withoutSceneAPI) out(]]

  ---Link audio to a node. Switches `setPosition()` to operate in local coordinates. Also, alters the velocity based on node velocity.
  ---@param sceneReference ac.SceneReference? @Set to `nil` to unlink the light source.
  ---@return self
  linkTo = function (s, sceneReference) 
    return __util.native('lj_audioevent_linkto', s, sceneReference)
  end,

  --[[) ?]]

  ---Override used volume channel. Use carefully.
  ---@param channel ac.AudioChannel? @Set to `nil` to reset to default.
  ---@return self
  setVolumeChannel = function (s, channel) 
    return __util.native('lj_audioevent_linkvolume', s, channel)
  end,

  ---Deprecated, now all events are alive until `:dispose()` is called.
  ---@deprecated
  keepAlive = function () end,

  ---Set value of an audio event parameter.
  ---@param name string
  ---@param value number
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setParam = function (s, name, value) ffi.C.lj_audioevent_set_param(s, __util.str(name), tonumber(value) or 0) return s end,

  ---Set minimum distance at which attenuation starts.
  ---@param value number
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setDistanceMin = function (s, value) ffi.C.lj_audioevent_set_distance_min(s, tonumber(value) or 1) return s end,

  ---Set maximum distance at which attenuation ends.
  ---@param value number
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setDistanceMax = function (s, value) ffi.C.lj_audioevent_set_distance_max(s, tonumber(value) or 10) return s end,

  ---Set 3D cone settings.
  ---@param inside number? @Default value: 360.
  ---@param outside number? @Default value: 360.
  ---@param outsideVolume number? @Default value: 1.
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setConeSettings = function (s, inside, outside, outsideVolume) ffi.C.lj_audioevent_set_cone_settings(s, tonumber(inside) or 360, tonumber(outside) or 360, tonumber(outsideVolume) or 1) return s end,

  ---Set DSP parameter.
  ---@param dsp integer @0-based index of DSP.
  ---@param key integer @0-based index of DSP parameter.
  ---@param value number
  ---@return ac.AudioEvent @Returns self for easy chaining.
  setDSPParameter = function (s, dsp, key, value) ffi.C.lj_audioevent_set_dsp_param(s, tonumber(dsp) or 0, tonumber(key) or 0, tonumber(value) or 0) return s end,

  ---Returns `true` if event is loaded successfully. If event does not load, make sure soundbank is loaded first, and that event name is correct. If event is loaded
  ---from a file and finished playing, also returns `false`.
  ---@return boolean
  isValid = ffi.C.lj_audioevent_is_valid,

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
  isWithinRange = function (s) ffi.C.lj_audioevent_is_within_range(s) return s end,

  resume = function (s) ffi.C.lj_audioevent_resume(s) return s end,

  ---If condition is `true`, start an audio event if it’s stopped, resume it if it’s paused. If condition is false, stop audio event.
  ---@param condition boolean
  ---@return ac.AudioEvent @Returns self for easy chaining.
  resumeIf = function (s, condition) ffi.C.lj_audioevent_resume_if(s, condition) return s end,

  ---Stop audio event.
  ---@return ac.AudioEvent @Returns self for easy chaining.
  stop = function (s) ffi.C.lj_audioevent_stop(s) return s end,

  ---Start audio event.
  ---@return ac.AudioEvent @Returns self for easy chaining.
  start = function (s) ffi.C.lj_audioevent_start(s) return s end,

  ---Set timeline position.
  ---@param time number @Time in seconds.
  ---@return ac.AudioEvent @Returns self for easy chaining.
  seek = function (s, time) ffi.C.lj_audioevent_seek(s, time) return s end,

  ---Get current timeline position in seconds.
  ---@return number @Returns `-1` if actual position is not available.
  getTimelinePosition = function (s) return ffi.C.lj_audioevent_timelineposition(s) end,

  ---Get total duration in seconds for an audio event loaded from a file.
  ---@return number @Returns `-1` if actual duration is not available.
  getDuration = function (s) return ffi.C.lj_audioevent_duration(s) end,

  ---If you need to move audio event often, accessing its matrix directly might be the best way. But you have to be extra careful in
  ---making sure matrix is always normalized (vectors `side`, `up` and `look` should be othrogonal with lengths of 1), otherwise
  ---audio might sound strange, with rapid changes in volume.
  ---@return mat4x4
  getTransformationRaw = function (s) return s.transform_ end,

  ---Stop and remove audio event.
  dispose = function (s) table.removeItem(__audioEventKeepAlive, s) ffi.C.lj_audioevent_dispose(s) end,

  ---@param i integer
  ---@param dir 'input'|'output'|'both'|nil
  ---@return number, number, number, number
  getDSPMetering = function (s, i, dir)
    return __util.native('ac.AudioEvent.getDSPMetering', s, i, dir)
  end,
}})
