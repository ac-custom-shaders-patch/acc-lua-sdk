__source 'lua/api_color_corrections.cpp'

---@class ac.ColorCorrectionBase : ClassBase
---@virtual-class ac.ColorCorrectionBase

---Grayscale filter.
---@class ac.ColorCorrectionGrayscale : ac.ColorCorrectionBase
---@constructor fun(): ac.ColorCorrectionGrayscale
ffi.cdef [[ typedef struct { void* __vfptr; } cc_grayscale; ]]
ffi.metatype('cc_grayscale', { __index = {} })
ac.ColorCorrectionGrayscale = function () return ffi.gc(ffi.C.lj_cc_grayscale_new(), ffi.C.lj_cc_grayscale_gc) end

---Negative filter.
---@class ac.ColorCorrectionNegative : ac.ColorCorrectionBase
---@constructor fun(): ac.ColorCorrectionNegative
ffi.cdef [[ typedef struct { void* __vfptr; } cc_negative; ]]
ffi.metatype('cc_negative', { __index = {} })
ac.ColorCorrectionNegative = function () return ffi.gc(ffi.C.lj_cc_negative_new(), ffi.C.lj_cc_negative_gc) end

---Sepia filter.
---@class ac.ColorCorrectionSepiaTone : ac.ColorCorrectionBase
---@field value number @Intensity from 0 to 1.
---@constructor fun(t: nil|{ value: number } "Table with parameters."): ac.ColorCorrectionSepiaTone
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_sepiatone; ]]
ffi.metatype('cc_sepiatone', { __index = {} })
ac.ColorCorrectionSepiaTone = function (t) 
  local r = ffi.C.lj_cc_sepiatone_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_sepiatone_gc) 
end


---Brightness filter.
---@class ac.ColorCorrectionBrightness : ac.ColorCorrectionBase
---@field value number @Brightness, 1 for normal.
---@constructor fun(t: nil|{ value: number } "Table with parameters."): ac.ColorCorrectionBrightness
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_brightness; ]]
ffi.metatype('cc_brightness', { __index = {} })
ac.ColorCorrectionBrightness = function (t) 
  local r = ffi.C.lj_cc_brightness_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_brightness_gc) 
end


---Saturation filter.
---@class ac.ColorCorrectionSaturation : ac.ColorCorrectionBase
---@field value number @Saturation, 1 for normal.
---@constructor fun(t: nil|{ value: number } "Table with parameters."): ac.ColorCorrectionSaturation
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_saturation; ]]
ffi.metatype('cc_saturation', { __index = {} })
ac.ColorCorrectionSaturation = function (t) 
  local r = ffi.C.lj_cc_saturation_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_saturation_gc) 
end


---Contrast filter.
---@class ac.ColorCorrectionContrast : ac.ColorCorrectionBase
---@field value number @Contrast, 1 for normal.
---@constructor fun(t: nil|{ value: number } "Table with parameters."): ac.ColorCorrectionContrast
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_contrast; ]]
ffi.metatype('cc_contrast', { __index = {} })
ac.ColorCorrectionContrast = function (t) 
  local r = ffi.C.lj_cc_contrast_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_contrast_gc) 
end


---Bias filter (shifts color values: result=original+value).
---@class ac.ColorCorrectionBias : ac.ColorCorrectionBase
---@field value number @Value, 0 for no shift.
---@constructor fun(t: nil|{ value: number } "Table with parameters."): ac.ColorCorrectionBias
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_bias; ]]
ffi.metatype('cc_bias', { __index = {} })
ac.ColorCorrectionBias = function (t) 
  local r = ffi.C.lj_cc_bias_new() 
  r.value = type(t) == 'table' and t['value'] or t or 0.0
  return ffi.gc(r, ffi.C.lj_cc_bias_gc) 
end


---Modulation (RGB) filter (multiplies color values: result=original*color).
---@class ac.ColorCorrectionModulationRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@constructor fun(t: nil|{ color: rgb } "Table with parameters."): ac.ColorCorrectionModulationRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_modulation_rgb; ]]
ffi.metatype('cc_modulation_rgb', { __index = {} })
ac.ColorCorrectionModulationRgb = function (t) 
  local r = ffi.C.lj_cc_modulation_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_modulation_rgb_gc) 
end


---Saturation (color) filter.
---@class ac.ColorCorrectionSaturationRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@constructor fun(t: nil|{ color: rgb } "Table with parameters."): ac.ColorCorrectionSaturationRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_saturation_rgb; ]]
ffi.metatype('cc_saturation_rgb', { __index = {} })
ac.ColorCorrectionSaturationRgb = function (t) 
  local r = ffi.C.lj_cc_saturation_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_saturation_rgb_gc) 
end


---Contrast (color) filter.
---@class ac.ColorCorrectionContrastRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@constructor fun(t: nil|{ color: rgb } "Table with parameters."): ac.ColorCorrectionContrastRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_contrast_rgb; ]]
ffi.metatype('cc_contrast_rgb', { __index = {} })
ac.ColorCorrectionContrastRgb = function (t) 
  local r = ffi.C.lj_cc_contrast_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_contrast_rgb_gc) 
end


---Bias (color) filter.
---@class ac.ColorCorrectionBiasRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 0 by default.
---@constructor fun(t: nil|{ color: rgb } "Table with parameters."): ac.ColorCorrectionBiasRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_bias_rgb; ]]
ffi.metatype('cc_bias_rgb', { __index = {} })
ac.ColorCorrectionBiasRgb = function (t) 
  local r = ffi.C.lj_cc_bias_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb()
  return ffi.gc(r, ffi.C.lj_cc_bias_rgb_gc) 
end


---Monotone filter.
---@class ac.ColorCorrectionMonotoneRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@field effectRatio number @Effect ratio, 1 by default.
---@constructor fun(t: nil|{ color: rgb, effectRatio: number } "Table with parameters."): ac.ColorCorrectionMonotoneRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_monotone_rgb; ]]
ffi.metatype('cc_monotone_rgb', { __index = {} })
ac.ColorCorrectionMonotoneRgb = function (t) 
  local r = ffi.C.lj_cc_monotone_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
  return ffi.gc(r, ffi.C.lj_cc_monotone_rgb_gc) 
end


---Monotone filter.
---@class ac.ColorCorrectionMonotoneRgbSatMod : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@field saturation number @Saturation, 1 by default.
---@field modulation number @Modulation, 1 by default.
---@constructor fun(t: nil|{ color: rgb, saturation: number, modulation: number } "Table with parameters."): ac.ColorCorrectionMonotoneRgbSatMod
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float saturation; float modulation; } cc_monotone_rgbsatmod; ]]
ffi.metatype('cc_monotone_rgbsatmod', { __index = {} })
ac.ColorCorrectionMonotoneRgbSatMod = function (t) 
  local r = ffi.C.lj_cc_monotone_rgbsatmod_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.saturation = type(t) == 'table' and t['saturation'] or 1
  r.modulation = type(t) == 'table' and t['modulation'] or 1
  return ffi.gc(r, ffi.C.lj_cc_monotone_rgbsatmod_gc) 
end


---Fade filter.
---@class ac.ColorCorrectionFadeRgb : ac.ColorCorrectionBase
---@field color rgb @Value, 1 by default.
---@field effectRatio number @Effect ratio, 1 by default.
---@constructor fun(t: nil|{ color: rgb, effectRatio: number } "Table with parameters."): ac.ColorCorrectionFadeRgb
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_fade_rgb; ]]
ffi.metatype('cc_fade_rgb', { __index = {} })
ac.ColorCorrectionFadeRgb = function (t) 
  local r = ffi.C.lj_cc_fade_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
  return ffi.gc(r, ffi.C.lj_cc_fade_rgb_gc) 
end


---Hue filter.
---@class ac.ColorCorrectionHue : ac.ColorCorrectionBase
---@field hue number @Hue offset, 0 by default.
---@field keepLuminance boolean @Ensure luminance wouldn’t change, true by default.
---@constructor fun(t: nil|{ hue: number, keepLuminance: boolean } "Table with parameters."): ac.ColorCorrectionHue
ffi.cdef [[ typedef struct { void* __vfptr; float hue; bool keepLuminance; } cc_hue; ]]
ffi.metatype('cc_hue', { __index = {} })
ac.ColorCorrectionHue = function (t) 
  local r = ffi.C.lj_cc_hue_new() 
  r.hue = type(t) == 'table' and t['hue'] or t or 0
  r.keepLuminance = type(t) == 'table' and t['keepLuminance'] or true
  return ffi.gc(r, ffi.C.lj_cc_hue_gc) 
end


---HSB (hue, saturation, brightness) filter.
---@class ac.ColorCorrectionHsb : ac.ColorCorrectionBase
---@field hue number @Hue offset, 0 by default.
---@field saturation number @Saturation, 1 by default.
---@field brightness number @Brightness, 1 by default.
---@constructor fun(t: nil|{ hue: number, saturation: number, brightness: number } "Table with parameters."): ac.ColorCorrectionHsb
ffi.cdef [[ typedef struct { void* __vfptr; float hue; float saturation; float brightness; } cc_hsb; ]]
ffi.metatype('cc_hsb', { __index = {} })
ac.ColorCorrectionHsb = function (t) 
  local r = ffi.C.lj_cc_hsb_new() 
  r.hue = type(t) == 'table' and t['hue'] or t or 0
  r.saturation = type(t) == 'table' and t['saturation'] or t or __util.num_or(t, 1)
  r.brightness = type(t) == 'table' and t['brightness'] or t or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_hsb_gc) 
end


---Temperature filter.
---@class ac.ColorCorrectionTemperature : ac.ColorCorrectionBase
---@field temperature number @Temperature, 6500 by default.
---@field luminance number @Luminance, 0 by default.
---@constructor fun(t: nil|{ temperature: number, luminance: number } "Table with parameters."): ac.ColorCorrectionTemperature
ffi.cdef [[ typedef struct { void* __vfptr; float temperature; float luminance; } cc_temperature; ]]
ffi.metatype('cc_temperature', { __index = {} })
ac.ColorCorrectionTemperature = function (t) 
  local r = ffi.C.lj_cc_temperature_new() 
  r.temperature = type(t) == 'table' and t['temperature'] or __util.num_or(t, 6500.0)
  r.luminance = type(t) == 'table' and t['luminance'] or 0.0
  return ffi.gc(r, ffi.C.lj_cc_temperature_gc) 
end


---White balance filter.
---@class ac.ColorCorrectionWhiteBalance : ac.ColorCorrectionBase
---@field whitebalance number @White balance, 6500 by default.
---@field luminance number @Luminance, 0 by default.
---@constructor fun(t: nil|{ whitebalance: number, luminance: number } "Table with parameters."): ac.ColorCorrectionWhiteBalance
ffi.cdef [[ typedef struct { void* __vfptr; float whitebalance; float luminance; } cc_whitebalance; ]]
ffi.metatype('cc_whitebalance', { __index = {} })
ac.ColorCorrectionWhiteBalance = function (t) 
  local r = ffi.C.lj_cc_whitebalance_new() 
  r.temperature = type(t) == 'table' and t['temperature'] or __util.num_or(t, 6500.0)
  r.luminance = type(t) == 'table' and t['luminance'] or 0.0
  return ffi.gc(r, ffi.C.lj_cc_whitebalance_gc) 
end
