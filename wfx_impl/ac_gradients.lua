ffi.cdef [[ 
typedef struct {
  vec3 direction;
  float sizeFull, sizeStart;
  bool isAdditive;
  bool isIncludedInCalculate;

  struct {
    rgb color;
    float exponent;
  };
} extragradient;
]]

ffi.metatype('extragradient', { __index = {} })

---@class ac.SkyExtraGradient
---@field direction vec3
---@field sizeFull number
---@field sizeStart number
---@field isAdditive boolean
---@field isIncludedInCalculate boolean
---@field color rgb
---@field exponent number
---@constructor fun(t: { direction: vec3, sizeFull: number, sizeStart: number, isAdditive: boolean, isIncludedInCalculate: boolean, color: rgb, exponent: number }?): ac.SkyExtraGradient

function ac.SkyExtraGradient(t)
  local r = ffi.C.lj_extragradient_new__impl()
  if type(t) == 'table' then
    if vec3.isvec3(t.direction) then r.direction = t.direction end
    if rgb.isrgb(t.color) then r.color = t.color end
    if type(t.sizeFull) == 'number' then r.sizeFull = t.sizeFull end
    if type(t.sizeStart) == 'number' then r.sizeStart = t.sizeStart end
    if type(t.exponent) == 'number' then r.exponent = t.exponent end
    if type(t.isAdditive) == 'boolean' then r.isAdditive = t.isAdditive end
    if type(t.isIncludedInCalculate) == 'boolean' then r.isIncludedInCalculate = t.isIncludedInCalculate end
  end
  return ffi.gc(r, ffi.C.lj_extragradient_gc__impl)
end