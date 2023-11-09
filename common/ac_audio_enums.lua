ac.AudioDSP = __enum({ underlying = 'string' }, {
	Oscillator = "oscillator",         --- Generates sine/square/saw/triangle or noise tones.
	LowPass = "lowpass",            --- Filters sound using a high quality, resonant lowpass filter algorithm but consumes more CPU time.
	ITLowPass = "itlowpass",          --- Filters sound using a resonant lowpass filter algorithm that is used in Impulse Tracker, but with limited cutoff range (0 to 8060hz).
	HighPass = "highpass",           --- Filters sound using a resonant highpass filter algorithm.
	Echo = "echo",               --- Produces an echo on the sound and fades out at the desired rate.
	Fader = "fader",              --- Pans and scales the volume of a unit.
	Flange = "flange",             --- Produces a flange effect on the sound.
	Distortion = "distortion",         --- Distorts the sound.
	Normalize = "normalize",          --- Normalizes or amplifies the sound to a certain level.
	Limiter = "limiter",            --- Limits the sound to a certain level.
	ParamEQ = "parameq",            --- Attenuates or amplifies a selected frequency range.
	PitchShift = "pitchshift",         --- Bends the pitch of a sound without changing the speed of playback.
	Chorus = "chorus",             --- Produces a chorus effect on the sound.
	SFXReverb = "sfxreverb",          --- Implements SFX reverb
	LowPassSimple = "lowpasssimple",     --- Filters sound using a simple lowpass with no resonance, but has flexible cutoff and is fast.
	Delay = "delay",              --- Produces different delays on individual channels of the sound.
	Tremolo = "tremolo",            --- Produces a tremolo / chopper effect on the sound.
	HighPassSimple = "highpasssimple",    --- Filters sound using a simple highpass with no resonance, but has flexible cutoff and is fast.
	Pan = "pan",                --- Pans the signal, possibly upmixing or downmixing as well.
	ThreeEQ = "threeeq",           --- Is a three-band equalizer.
})
