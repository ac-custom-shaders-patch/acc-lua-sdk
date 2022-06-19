ffi.cdef [[
typedef struct {
  rgb colorMultiplier;
  float opacityMultiplier;

  rgb colorExponent;
  float opacityExponent;

  float opacityCutoff;
  float opacityFade;
  float texOffsetX;
  float texRemapY;

  float fogMultZenith;
  float fogMultDelta;
  float fogRangeInv;
  float fogMultExponent;

  float shadowRadius;
  float shadowOpacityMultiplier;
  float maskOpacityMultiplier;
  float texScaleX;

  bool ignoreTextureAlpha;
} cloudscover;
]]


---Special cloud-like thing for drawing 360° cloud textures.
---@class ac.SkyCloudsCover
---@field colorMultiplier rgb
---@field opacityMultiplier number
---@field colorExponent rgb
---@field opacityExponent number
---@field opacityCutoff number
---@field opacityFade number
---@field texOffsetX number
---@field texRemapY number
---@field fogMultZenith number
---@field fogMultDelta number
---@field fogRangeInv number
---@field fogMultExponent number
---@field shadowRadius number
---@field shadowOpacityMultiplier number
---@field maskOpacityMultiplier number
---@field texScaleX number
---@field ignoreTextureAlpha boolean @If set to `true`, texture alpha is only used for main rendering pass, not for casting shadow. Default value: `false`.
---@constructor fun(): ac.SkyCloudsCover
ffi.metatype('cloudscover', {
  __index = {

    ---@param filename string
    ---@param maxSize number? @If non-zero, sets a maximum size for MIPs to load. Any MIPs larger than that will be skipped. Only works with BC6H/BC7 compression, or with DXT1/3/5/RGBA8888 if using new loader option is enabled.
    setTexture = function (s, filename, maxSize) ffi.C.lj_cloudscover_set_texture__impl(s, tostring(filename), tonumber(maxSize) or 0) end,

    getTextureState = ffi.C.lj_cloudscover_get_texture_state__impl,

    ---@param filename string
    ---@param maxSize number? @If non-zero, sets a maximum size for MIPs to load. Any MIPs larger than that will be skipped. Only works with BC6H/BC7 compression, or with DXT1/3/5/RGBA8888 if using new loader option is enabled.
    setMaskTexture = function (s, filename, maxSize) ffi.C.lj_cloudscover_set_mask_texture__impl(s, tostring(filename), tonumber(maxSize) or 0) end,

    getMaskTextureState = ffi.C.lj_cloudscover_get_mask_texture_state__impl,
    
    setFogParams = function (s, fogHorizon, fogZenith, fogExponent, fogRangeMult)
      s.fogMultZenith = tonumber(fogZenith) or 1
      s.fogMultDelta = (tonumber(fogHorizon) or 1) - s.fogMultZenith
      s.fogRangeInv = 1 / math.max(0.01, tonumber(fogRangeMult) or 1)
      s.fogMultExponent = tonumber(fogExponent) or 1
    end
  }
})
function ac.SkyCloudsCover() return ffi.gc(ffi.C.lj_cloudscover_new__impl(), ffi.C.lj_cloudscover_gc__impl) end
