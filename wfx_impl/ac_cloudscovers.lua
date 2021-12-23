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
---@constructor fun(): ac.SkyCloudsCover
ffi.metatype('cloudscover', {
  __index = {
    setTexture = ffi.C.lj_cloudscover_set_texture__impl,
    getTextureState = ffi.C.lj_cloudscover_get_texture_state__impl,
    setFogParams = function (s, fogHorizon, fogZenith, fogExponent, fogRangeMult)
      s.fogMultZenith = tonumber(fogZenith) or 1
      s.fogMultDelta = (tonumber(fogHorizon) or 1) - s.fogMultZenith
      s.fogRangeInv = 1 / math.max(0.01, tonumber(fogRangeMult) or 1)
      s.fogMultExponent = tonumber(fogExponent) or 1
    end
  }
})
function ac.SkyCloudsCover() return ffi.gc(ffi.C.lj_cloudscover_new__impl(), ffi.C.lj_cloudscover_gc__impl) end
