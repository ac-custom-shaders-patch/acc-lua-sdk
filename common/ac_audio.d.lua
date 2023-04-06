---Create a new audio event from previously loaded soundbank.
---@param eventName string @Event name, for example, `'/cars/lada_revolution/door'` (leading “/” or “event:” prefix are optional).
---@param reverbResponse boolean @Set to true if audio event should be affected by reverb in tunnels and such.
---@return ac.AudioEvent
function ac.AudioEvent(eventName, reverbResponse) end

---Create a new audio event from a file. Consequent calls with the same parameters would reuse previously loaded audio file.
--[[@tableparam params {
  filename: string "Audio filename",
  stream: {name: string, size: integer} = nil "Audio stream (as an alternative to `filename` for live streaming data using a memory mapped file)",
  use3D: boolean = true "Set to `false` to load audio without any 3D effects",
  loop: boolean = true "Set to `false` to disable audio looping",
  insideConeAngle: number = nil "Angle in degrees at which audio is at 100% volume",
  outsideConeAngle: number = nil "Angle in degrees at which audio is at `outsideVolume` volume",
  outsideVolume: number = nil "Volume multiplier if listener is outside of the cone",
  minDistance: number = nil "Distance at which audio would stop going louder as it approaches listener (default is 1)",
  maxDistance: number = nil "Distance at which audio would attenuating as it gets further away from listener (default is 10 km)",
  dopplerEffect: number = nil "Scale for doppler effect",
  dsp: ac.AudioDSP[] = nil "IDs of DSPs to add"
}]]
---@param reverbResponse boolean @Set to true if audio event should be affected by reverb in tunnels and such.
---@return ac.AudioEvent
function ac.AudioEvent.fromFile(params, reverbResponse) end

