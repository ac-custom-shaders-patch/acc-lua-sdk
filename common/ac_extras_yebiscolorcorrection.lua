__source 'lua/api_extras_yebiscolorcorrection.cpp'

ffi.cdef [[ 
typedef struct {
  void* __something;
} oycc_data;
]]

local _oycs = {}
function _oycs.color(v, d)
  if rgb.isrgb(v) then
    return v.r, v.g, v.b
  elseif rgbm.isrgbm(v) then
    return math.lerp(d, v.r, v.mult), math.lerp(d, v.g, v.mult), math.lerp(d, v.b, v.mult)
  else
    v = tonumber(v) or d
    return v, v, v
  end
end

---Helper entity to set color corrections. Holds up to 200 corrections at once. Call `:reset()` if you want to start over, or just use `ac.setColorCorrection()` the way it’s meant to be used.
---@class ac.ColorCorrection
ffi.metatype('oycc_data', {
  __index = {
    ---Reset alterations.
    ---@return self
    reset = function (s) ffi.C.lj_oycc_5f(s, -1, 0, 0, 0, 0, 0) return s end,

    ---Completely desaturate the image.
    ---@return self
    grayscale = function (s) ffi.C.lj_oycc_5f(s, 11, 0, 0, 0, 0, 0) return s end,

    ---Invert image colors.
    ---@return self
    negative = function (s) ffi.C.lj_oycc_5f(s, 12, 0, 0, 0, 0, 0) return s end,

    ---Change image saturation.
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 1.
    ---@return self
    saturation = function (s, v) local r, g, b = _oycs.color(v, 1) ffi.C.lj_oycc_5f(s, 0, r, g, b, 0, 0) return s end,

    ---Change image brightness (multiplies color by the parameter).
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 1.
    ---@return self
    brightness = function (s, v) local r, g, b = _oycs.color(v, 1) ffi.C.lj_oycc_5f(s, 1, r, g, b, 0, 0) return s end,

    ---Change image contrast.
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 1.
    ---@return self
    contrast = function (s, v) local r, g, b = _oycs.color(v, 1) ffi.C.lj_oycc_5f(s, 2, r, g, b, 0, 0) return s end,

    ---Change image bias (adds the parameter to color).
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 0.
    ---@return self
    bias = function (s, v) local r, g, b = _oycs.color(v, 0) ffi.C.lj_oycc_5f(s, 3, r, g, b, 0, 0) return s end,

    ---Add a fadeout transformation.
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 0.
    ---@return self
    fade = function (s, v, effectRatio) 
      if rgbm.isrgbm(v) then return s:fade(v.rgb, (tonumber(effectRatio) or 1) * v.mult) end
      local r, g, b = _oycs.color(v, 0)
      ffi.C.lj_oycc_5f(s, 4, r, g, b, tonumber(effectRatio) or 1, 0)
      return s
    end,

    ---Turn image monotone.
    ---@param v number|rgb|rgbm? @Fourth component of rgbm acts as an intensity adjustment. Default value: 0.
    ---@param saturation number? @Saturation factor. Default value: 0.
    ---@param brightness number? @Brightness factor. Default value: 1.
    ---@return self
    monotone = function (s, v, saturation, brightness) 
      if rgbm.isrgbm(v) then return s:monotone(v.rgb, math.lerp(1, tonumber(saturation) or 0, v.mult), (tonumber(brightness) or 1) * v.mult) end
      local r, g, b = _oycs.color(v, 0)
      ffi.C.lj_oycc_5f(s, 6, r, g, b, tonumber(saturation) or 0, tonumber(brightness) or 1) 
      return s
    end,

    ---Alter hue, saturation and brightness.
    ---@param hueDegrees number? @Degrees for hue shift. Default value: 0.
    ---@param saturation number? @Saturation adjustment. Default value: 1.
    ---@param brightness number? @Brightness adjustment. Default value: 1.
    ---@param keepLuminance boolean? @Keep image luminance. Default value: `false`.
    ---@return self
    HSB = function (s, hueDegrees, saturation, brightness, keepLuminance)       
      ffi.C.lj_oycc_5f(s, 5, tonumber(hueDegrees) or 0, tonumber(saturation) or 1, tonumber(brightness) or 1, keepLuminance and 1 or 0, 0)
      return s
    end,

    ---Alter image white balance.
    ---@param temperatureK number? @Temperature in K. Default value: 6500.
    ---@param luminance number? @Luminance. Default value: 1.
    ---@return self
    whiteBalance = function (s, temperatureK, luminance) ffi.C.lj_oycc_5f(s, 7, tonumber(temperatureK) or 6500, tonumber(luminance) or 1, 0, 0, 0) end,

    ---Alter image temperature.
    ---@param temperatureK number? @Temperature in K. Default value: 6500.
    ---@param luminance number? @Luminance. Default value: 1.
    ---@return self
    temperature = function (s, temperatureK, luminance) ffi.C.lj_oycc_5f(s, 8, tonumber(temperatureK) or 6500, tonumber(luminance) or 1, 0, 0, 0) end,

    ---Shift tone to sepia.
    ---@param v number? @Sepia amount. Default value: 1.
    ---@return self
    sepia = function (s, v) ffi.C.lj_oycc_5f(s, 9, tonumber(v) or 1, 0, 0, 0, 0) return s end,

    ---Shift image hue.
    ---@param hueDegrees number? @Degrees for hue shift. Default value: 0.
    ---@param keepLuminance boolean? @Keep image luminance. Default value: `false`.
    ---@return self
    hue = function (s, hueDegrees, keepLuminance) ffi.C.lj_oycc_5f(s, 10, tonumber(hueDegrees) or 0, keepLuminance and 1 or 0, 0, 0, 0) return s end,
  }
})

---YEBIS uses color matrices to quickly adjust HDR (input 0…∞ range) and LDR (output 0…1 range) color. Tweaks such as saturation, brightness and
---contrast configured in YEBIS PP filter, or in video settings, all control those matrices.
---
---This function allows to easily tweak those matrices. Call it, optionally specifying target matrix and priority, and then use methods of returned
---entity to easily tweak the color. Chain methods together to achieve the desired effect:
---```
---ac.setColorCorrection():brightness(3):saturation(2)
---```
---
---Won’t have any effect if YEBIS is disabled, or if WeatherFX style script replaces YEBIS post-processing and doesn’t read
---HDR matrix correctly. For compatibility reasons, if WeatherFX style script doesn’t read LDR color matrix, it will be applied
---afterwards (in CSPs before 0.2.5, there wasn’t a method for WeatherFX style scripts to even access LDR color matrix, and
---Assetto Corsa didn’t alter it at all).
---
---Each time the function is called with the same target and priority parameters, its state will reset. Feel free to call this function every frame
---if you want for adjustments to transition smoothly, or just once if you just want to tweak the colors and forget about it.
---
---Note: you can keep a reference to returned value and tweak it instead, but then you’ll have to call `:reset()` manually. One tweak entity can
---hold up to 40 adjustments, mostly to make sure it’s used correctly. Actual adjustments are very cheap.
---
---Note: some scripts, such as online scripts, can access old API for color corrections, such as `ac.ColorCorrectionBrightness()`.
---Those things are obsolete now, please use this thing instead (with only exception being WeatherFX styles, those could still
---old API since it could be a tiny bit faster overall).
---@param targetLDR boolean? @Set to `true` to alter final LDR image instead of original HDR image. Note: original AC never tweaked LDR color matrix at all. Default value: `false`.
---@param priority integer? @Specifies order of execution. Higher numbers mean corrections will apply first. Can be an integer in -100…100 range. Default value: `0`.
---@return ac.ColorCorrection
function ac.setColorCorrection(targetLDR, priority)
  targetLDR = not not targetLDR
  priority = priority or 0
  local k = bit.bxor(targetLDR and (1024 * 1024 - 1) or 0, priority)
  local r = _oycs[k]
  if not r then
    r = ffi.gc(ffi.C.lj_oycc_init(targetLDR, priority), ffi.C.lj_oycc_release)
    _oycs[k] = r
  end
  r:reset()
  return r
end
