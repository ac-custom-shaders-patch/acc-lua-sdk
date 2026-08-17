---Create a new audio event from previously loaded soundbank.
---@param event string|{event: string, dsp: ac.AudioDSP[]?} @Event name, for example, `'/cars/lada_revolution/door'` (leading “/” or “event:” prefix are optional). Since 0.3.0-preview147, you can use `:own` or `:0` (0-based car index) instead of car ID, so your logic could work if car uses sound from a different car. For example, `'cars/:own/engine_ext'` or `'cars/:1/engine_int'`. Remember, when writing CSP car config for a car you can use `[AUDIO_REDIRECT] CARS=primary_car_id, secondary_candidate` to use audio from existing car instead (the first one found would be used), or `[AUDIO_REDIRECT] SHARED=…` to load one of the shared remote audiobanks.
---@param reverbResponse boolean @Set to true if audio event should be affected by reverb in tunnels and such.
---@param useOcclusion boolean? @Set to true if audio event should be affected by walls on configured tracks. Default value: `false`. Car audio events are always occluded if 2D.
---@return ac.AudioEvent
function ac.AudioEvent(event, reverbResponse, useOcclusion) end

---Create a new audio event from a file. Consequent calls with the same parameters would reuse previously loaded audio file.
---Note: if `loop` is set to `false` when used with `filename`, audio event will become invalid once played once. Feel free to dispose the old one
---and create a new audio event.
--[[@tableparam params {
  filename: string "Audio filename",
  stream: {name: string, size: integer} = nil "Audio stream (as an alternative to `filename` for live streaming data using a memory mapped file)",
  group: ac.AudioEvent = nil "Optional audio event group",
  use3D: boolean = true "Set to `false` to load audio without any 3D effects",
  useOcclusion: boolean = nil "Set to `true` to let audio occlude based on track geometry (for configured tracks, 3D audio events only)",
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

---Create a new audio event group for audio events created from files.
--[[@tableparam params {
  group: ac.AudioEvent = nil "Optional audio event group",
  use3D: boolean = true "Set to `false` to load audio without any 3D effects",
  useOcclusion: boolean = nil "Set to `true` to let audio occlude based on track geometry (for configured tracks, 3D audio events only)",
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
function ac.AudioEvent.group(params, reverbResponse) end

--[[? if (!ctx.flags.withoutSceneAPI) out(]]

---Link audio to a node. Switches `setPosition()` to operate in local coordinates. Also, alters the velocity based on node velocity.
---Since 0.2.8, can also be used to link audio to a car: just pass a car index (as a number) instead.
---@param sceneReference integer|ac.SceneReference? @Set to `nil` to unlink the light source.
---@return self
function _ac_AudioEvent:linkTo(sceneReference) end

--[[) ?]]