---@class ac.ParticlesMaterial
---@field emissiveBlend number
---@field diffuse number
---@field ambient number
ffi.cdef [[ typedef struct { float emissiveBlend, diffuse, ambient; } particles_material; ]]
ac.ParticlesMaterial = ffi.metatype('particles_material', { __index = {} })
