---@class ac.LightPollution
---@field position vec3
---@field radius number @Radius in meters.
---@field tint rgb
---@field density number
ffi.cdef [[ typedef struct { vec3 position; float radius; rgb tint; float density; } light_pollution; ]]
ac.LightPollution = ffi.metatype('light_pollution', { 
  __index = {},
  __tostring = function(v)
    return string.format('(position=%s, radius=%f, density=%f, tint=%s)', v.position, v.radius, v.density, v.tint)
  end,
})