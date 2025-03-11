__source 'lua/lua_shader.cpp'

local _fficdef, _ffic = ffi.cdef, ffi.C
local _rsUq = os.time()

ffi.cdef[[
typedef struct {
  void* data;
  int blend_mode;
  bool ready;
  bool direct_values_exchange;
  bool _pad0;
  bool _pad1;
  void* ps_shader;
  lua_string_ref _error_str;
  // cbuffer:
  void* _cb_vtable;
  int _cb_slot_;
  int _cb_size_;
  int _cb_checksum_;
  bool _cb_dirty_;
} lua_cshader_shader;
]]

local function _lsta(name)
  if string.find(name, '%p') then return string.format('tostring(textures["%s"])', name) end
  return string.format('tostring(textures.%s)', name)
end

local function _lsfg(templateCache, params, texSlots, ret)
  local p = {'return function(d, params, C)'}  
  local firstSlot = next(texSlots)
  if firstSlot then
    local stmode = templateCache.delayed == true and 'delay' or 'set'
    local stfa = templateCache.delayed == true and 'd.s, ' or ''
    p[#p + 1] = 'local textures = params.textures'
    local n = 1
    while texSlots[firstSlot + n] do
      n = n + 1
    end
    if n == 1 then
      p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_1(%s%d, %s)', stmode, stfa, firstSlot, _lsta(texSlots[firstSlot]))
    elseif n == 2 then
      p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_2(%s%d, %s, %s)', stmode, stfa, firstSlot, 
        _lsta(texSlots[firstSlot]), _lsta(texSlots[firstSlot + 1]))
    elseif n == 3 then
      p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_3(%s%d, %s, %s, %s)', stmode, stfa, firstSlot, 
        _lsta(texSlots[firstSlot]), _lsta(texSlots[firstSlot + 1]), _lsta(texSlots[firstSlot + 2]))
    elseif n == 4 then
      p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_4(%s%d, %s, %s, %s, %s)', stmode, stfa, firstSlot, 
        _lsta(texSlots[firstSlot]), _lsta(texSlots[firstSlot + 1]), _lsta(texSlots[firstSlot + 2]), _lsta(texSlots[firstSlot + 3]))
    elseif n >= 5 then
      p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_5(%s%d, %s, %s, %s, %s, %s)', stmode, stfa, firstSlot, 
        _lsta(texSlots[firstSlot]), _lsta(texSlots[firstSlot + 1]), _lsta(texSlots[firstSlot + 2]), _lsta(texSlots[firstSlot + 3]), _lsta(texSlots[firstSlot + 4]))
      n = 4
    end
    for k, v in pairs(texSlots) do
      if k > firstSlot + n then
        p[#p + 1] = string.format('C.lj_cshader_%stexture_slot_1(%s%d, %s)', stmode, stfa, k, _lsta(v))
      end
    end
  end

  if params.__values_bak then
    params.values = ret.d
  elseif params.values and next(params.values) then
    if params.directValuesExchange == true then
      p[#p + 1] = 'if type(params.values) == "table" then local cb, values = d.d, params.values'
      for k, v in pairs(params.values) do
        if mat4x4.ismat4x4(v) then
          p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s cb.%s:transposeSelf() end', k, k, k, k)
        else
          p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s end', k, k, k)
        end
      end
      p[#p + 1] = 'params.__values_bak = params.values params.values = cb end'

      for k, v in pairs(params.values) do
        ret.d[k] = v
      end
      params.__values_bak = params.values
      params.values = ret.d
    else
      p[#p + 1] = 'local cb, values = d.d, params.values'
      for k, v in pairs(params.values) do
        -- if mat4x4.ismat4x4(v) then
        --   p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s cb.%s:transposeSelf() end', k, k, k, k)
        -- else
        --   p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s end', k, k, k)
        -- end
        if mat4x4.ismat4x4(v) then
          p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s cb.%s:transposeSelf() end', k, k, k, k)
        elseif type(v) == 'number' then
          p[#p + 1] = string.format('cb.%s = values.%s or 0', k, k)
        elseif type(v) == 'boolean' then
          p[#p + 1] = string.format('cb.%s = values.%s and 1 or 0', k, k)          
        elseif vec2.isvec2(v) then
          p[#p + 1] = string.format('cb.%s = values.%s or __util.ensure_vec2(nil)', k, k)
        elseif vec3.isvec3(v) then
          p[#p + 1] = string.format('cb.%s = values.%s or __util.ensure_vec3(nil)', k, k)
        elseif vec4.isvec4(v) then
          p[#p + 1] = string.format('cb.%s = values.%s or __util.ensure_vec4(nil)', k, k)
        elseif rgb.isrgb(v) then
          p[#p + 1] = string.format('cb.%s = values.%s or __util.ensure_rgb(nil)', k, k)
        elseif rgbm.isrgbm(v) then
          p[#p + 1] = string.format('cb.%s = values.%s or __util.ensure_rgbm(nil)', k, k)
        else
          p[#p + 1] = string.format('if values.%s ~= nil then cb.%s = values.%s end', k, k, k)
        end
      end
    end
  end

  if templateCache.defaultBlendMode then
    p[#p + 1] = string.format('d.s.blend_mode = tonumber(params.blendMode) or %d', templateCache.defaultBlendMode)
  end

  p[#p + 1] = 'end'
  return table.concat(p, '\n')
end

local function createRsData2(params, templateCache)
  local ret = {}

  local inputTextures = nil
  local startingTextureSlot = templateCache.startingTextureSlot or 0

  local texSlots = {}
  if params.textures and next(params.textures) then
    local t = {}
    local l = table.map(params.textures, function (v, k) return k end)
    table.sort(l, function (a, b) return a < b end)
    for i = 1, #l do
      if i == 33 - startingTextureSlot then error('Too many textures', 3) end

      local key = l[i]
      local textureName = tostring(params.textures[key])
      local textureType = (textureName:match('3D$') or textureName:match('3D%.')) and 'Texture3D'
        or (textureName:match('Cube$') or textureName:match('Cube%.')) and 'TextureCube'
        or (textureName:match('Array$') or textureName:match('Array%.')) and 'Texture2DArray'
        or 'Texture2D'
      local dimension = key:match('%.[1234]$')
      if dimension then
        t[i] = string.format('%s<float%s> %s : register(t%d);', textureType, dimension:sub(2), key:sub(1, #key - 2), i - 1 + startingTextureSlot)
      else
        t[i] = string.format('%s %s : register(t%d);', textureType, key, i - 1 + startingTextureSlot)
      end
      texSlots[i - 1 + startingTextureSlot] = key
    end
    inputTextures = table.concat(t)
  end

  local inputValues = nil
  local ffiSize = 0
  local ffiCastName
  local directCompile
  if params.__values_bak then
    params.values = params.__values_bak
  end
  if params.values and next(params.values) then
    local items = table.map(params.values, function (v, k)
      if type(v) == 'number' or type(v) == 'boolean' then return { key = k, size = 1, type = 'float', ffiType = 'float' } end
      if vec2.isvec2(v) then return { key = k, size = 2, type = 'float2', ffiType = 'vec2' } end
      if vec3.isvec3(v) then return { key = k, size = 3, type = 'float3', ffiType = 'vec3' } end
      if rgb.isrgb(v) then return { key = k, size = 3, type = 'float3', ffiType = 'rgb' } end
      if hsv.ishsv(v) then return { key = k, size = 3, type = 'float3', ffiType = 'hsv' } end
      if vec4.isvec4(v) then return { key = k, size = 4, type = 'float4', ffiType = 'vec4' } end
      if rgbm.isrgbm(v) then return { key = k, size = 4, type = 'float4', ffiType = 'rgbm' } end
      if quat.isquat(v) then return { key = k, size = 4, type = 'float4', ffiType = 'quat' } end
      if mat4x4.ismat4x4(v) then
        return { key = k, size = 16, type = 'float4x4', ffiType = 'mat4x4' } 
      end
      error('Unsupported parameter type: '..tostring(v), 4)
    end)
    table.sort(items, function (a, b) return a.size > b.size or a.size == b.size and a.key < b.key end)
    local si, fi, currentPos = {}, { 'typedef struct {' }, 0
    local function onItemAdded(key, pos, size)
      if params.compileValuesMask and string.cspmatch(key, params.compileValuesMask) then
        local directCompilePiece = string.format('%s;%s;%s', pos, size, key) -- KEY is needed! not just for debugging
        directCompile = (directCompile and directCompile..'\n' or '')..directCompilePiece
      end
    end
    for i = 1, #items do
      local item = items[i]
      if item then
        si[#si + 1] = string.format('%s %s;', item.type, item.key)
        fi[#fi + 1] = string.format('%s %s;', item.ffiType, item.key)
        onItemAdded(item.key, currentPos, item.size)
        if item.size == 3 then
          local holePlugged = false
          for j = i + 1, #items do
            local plugItem = items[j]
            if plugItem and plugItem.size == 1 then
              si[#si + 1] = string.format('%s %s;', plugItem.type, plugItem.key)
              fi[#fi + 1] = string.format('%s %s;', plugItem.ffiType, plugItem.key)
              onItemAdded(item.key, currentPos + 3, 1)
              items[j] = false
              holePlugged = true
              break
            end
          end
          if not holePlugged then
            si[#si + 1] = string.format('float __gpad_%d__;', #si)
            fi[#fi + 1] = string.format('float __gpad_%d__;', #fi)
          end
          currentPos = currentPos + 4
        else
          currentPos = currentPos + item.size
        end
      end
    end
    if params.__existing_ffiSize then
      ffiSize = params.__existing_ffiSize
    else
      local ffiName = '__rsstrct'..tostring(_rsUq)
      _rsUq = _rsUq + 1
      fi[#fi + 1] = '}'..ffiName..';'
      _fficdef(table.concat(fi))
      ffiSize = ffi.sizeof(ffiName)
      ffiCastName = ffiName..'*'
    end
    inputValues = table.concat(si)
  end

  local inputLibs = nil
  if params.extensions then
    inputLibs = table.concat(params.extensions, ',')
  end

  local inputDefines = nil
  if params.defines then
    inputDefines = table.concat(table.map(params.defines, function (v, k)
      if not v then return '' end
      return string.format('#define %s %s\n', k, (type(v) == 'number' or type(v) == 'boolean') and tonumber(v) or v)
    end), '')
  end

  ret.s = ffi.C.lj_cshader_setup(params.async == true, inputLibs, inputDefines, inputTextures, inputValues, 
    params.shader, templateCache.template, ffiSize, params.cacheKey == false and -87194889 or tonumber(params.cacheKey) or 0, 
    params.directValuesExchange == true, params.__existing, directCompile)
  if params.__existing_data then
    ret.d = params.__existing_data
  elseif ffiCastName then
    ret.d = ffi.cast(ffiCastName, ret.s.data)
    if params.directValuesExchange == true then
      params.__existing = ret.s
      params.__existing_data = ret.d
      params.__existing_ffiSize = ffiSize
    end
  end
  -- ac.log(_lsfg(templateCache, params, texSlots, ret))
  ret.y = loadstring(_lsfg(templateCache, params, texSlots, ret))()
  return ret
end

local shaderTables = {}

function __util.getRsData2(params, templateCache)
  local templateCacheLC = templateCache.__cache
  local key = params.cacheKey or ''
  local lc = templateCacheLC[key]
  if not lc then
    lc = {}
    templateCacheLC[key] = lc
  end
  local r = lc[params.shader]
  if r == nil then
    r = createRsData2(params, templateCache)
    lc[params.shader] = r
    if not table.contains(shaderTables, templateCache) then
      shaderTables[#shaderTables + 1] = templateCache
    end
  elseif params.directValuesExchange and type(params.values) == 'table' then
    params.__values_bak = params.values
    params.values = r.d
  end
  return r
end

function __script.onGammaChange()
  for _, v in ipairs(shaderTables) do
    -- ac.log('clear', v.template, table.nkeys(v.__cache))
    table.clear(v.__cache)
  end
end

function __util.setShaderParams2(params, templateCache)
  if type(params) ~= 'table' then error('Table “params” is required', 3) end
  local d = __util.getRsData2(params, templateCache)
  local s = d.s
  if s.ready then    
    if s.ps_shader ~= nil then
      s._cb_dirty_ = true
      if not s.direct_values_exchange then
        s.blend_mode = 0xffffffff
      end    
      d:y(params, _ffic)
      return s
    end
    error(__util.strrefr(s._error_str), 3)
  end
  return nil
end

__definitions()

if render then
  function render.bindTexture(slot, texture)
    slot = tonumber(slot) or 0
    if slot < 0 or slot >= 10 then
      error('Only slots from 0 to 9 are supported at the moment', 2)
    end
    ffi.C.lj_cshader_settexture_slot_1(slot or 0, tostring(texture))
  end
end