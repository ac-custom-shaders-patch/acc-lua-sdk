require './ac_audio_enums'

ac.AudioEvent = setmetatable({
  fromFile = function(...)
    __util.lazy('lib_audio')
    return ac.AudioEvent.fromFile(...)
  end,
  group = function(...)
    __util.lazy('lib_audio')
    return ac.AudioEvent.group(...)
  end
}, {
  __call = function(_, ...)
    __util.lazy('lib_audio')
    return ac.AudioEvent(...)
  end
})
