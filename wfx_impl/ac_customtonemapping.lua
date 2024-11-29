local _sp_ctt = {template = 'tonemapping.fx', __cache = {}, startingTextureSlot = 4, delayed = true}

---Override current tonemapping function. If you’re using a table and need texture coordinates, add `__CSP_PROVIDE_TEXCOORDS = true` define.
---@param v ac.TonemapFunction|string|{textures: table, values: table, defines: table, shader: string, cacheKey: integer}
function ac.setPpTonemapFunction(v)
  if type(v) == 'table' then
    local dc = __util.setShaderParams2(v, _sp_ctt)
    if not dc then return end
    ffi.C.lj_setPpTonemapFunction_dynamic__impl(dc)
  elseif type(v) == 'string' then    
    ffi.C.lj_setPpTonemapFunction_str__impl(v)
  else
    ffi.C.lj_setPpTonemapFunction_base__impl(__util.cast_enum(v, 0, 14, 0))
  end
end

