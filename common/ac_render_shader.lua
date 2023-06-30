__source 'lua/lua_shader.cpp'

local _fficdef = ffi.cdef
local _rsUq = os.time()

ffi.cdef[[
typedef struct {
  void* _pad;
} lua_cshader_shader;

typedef struct {
  void* data_ptr;
  int blend_mode;
} lua_cshader_drawcall;
]]

local function createRsData(params, templateName, startingTextureSlot)
  local ret = {}

  local inputTextures = nil
  if not startingTextureSlot then startingTextureSlot = 0 end
  if params.textures then
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
    end
    inputTextures = table.concat(t)
  end

  local inputValues = nil
  local ffiSize = 0
  if params.values then
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
        ret.hasMatrices = true
        return { key = k, size = 16, type = 'float4x4', ffiType = 'mat4x4' } 
      end
      error('Unsupported parameter type: '..tostring(v), 4)
    end)
    table.sort(items, function (a, b) return a.size > b.size or a.size == b.size and a.key < b.key end)
    local si, fi = {}, { 'typedef struct {' }
    for i = 1, #items do
      local item = items[i]
      if item then
        si[#si + 1] = string.format('%s %s;', item.type, item.key)
        fi[#fi + 1] = string.format('%s %s;', item.ffiType, item.key)
        if item.size == 3 then
          local holePlugged = false
          for j = i + 1, #items do
            local plugItem = items[j]
            if plugItem and plugItem.size == 1 then
              si[#si + 1] = string.format('%s %s;', plugItem.type, plugItem.key)
              fi[#fi + 1] = string.format('%s %s;', plugItem.ffiType, plugItem.key)
              items[j] = false
              holePlugged = true
              break
            end
          end
          if not holePlugged then
            si[#si + 1] = string.format('float __gpad_%d__;', #si)
            fi[#fi + 1] = string.format('float __gpad_%d__;', #fi)
          end
        end
      end
    end
    local ffiName = '__rsstrct'..tostring(_rsUq)
    _rsUq = _rsUq + 1
    fi[#fi + 1] = '}'..ffiName..';'
    _fficdef(table.concat(fi))
    ffiSize = ffi.sizeof(ffiName)
    inputValues = table.concat(si)
    ret.ffiCastName = ffiName..'*'
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

  ret.s = ffi.C.lj_cshader_setup(params.async == true, inputLibs, inputDefines, inputTextures, inputValues, params.shader, templateName, ffiSize, tonumber(params.cacheKey) or -87194889)
  return ret
end

local _rsCache = {}

function __util.getRsData(params, templateName, startingTextureSlot)
  local k = ffi.C.lj_cshader_key(params.shader, templateName, tonumber(params.cacheKey) or -87194889)
  local r = _rsCache[k]
  if r == nil then
    r = createRsData(params, templateName, startingTextureSlot)
    _rsCache[k] = r
  end
  return r
end

function __util.setShaderParams(params, templateName, defaultBlendMode, startingTextureSlot)
  if type(params) ~= 'table' then error('Table “params” is required', 3) end

  local d = __util.getRsData(params, templateName, startingTextureSlot)
  local dc = ffi.C.lj_cshader_start(d.s)
  if dc == nil then return nil end

  if params.textures then
    for k, v in pairs(params.textures) do
      if ffi.C.lj_cshader_settexture(dc, tostring(k), v and tostring(v) or nil) == -1 then
        ffi.C.lj_cshader_release(dc)
        error('Unknown texture slot: '..tostring(k), 3)
      end
    end
  end

  if d.ffiCastName and params.values then
    local data = ffi.cast(d.ffiCastName, dc.data_ptr)
    if d.hasMatrices then
      for k, v in pairs(params.values) do
        data[k] = v
        if mat4x4.ismat4x4(v) then
          data[k]:transposeSelf()
        end
      end
    else
      for k, v in pairs(params.values) do
        data[k] = v
      end
    end
  end

  if defaultBlendMode then
    dc.blend_mode = tonumber(params.blendMode) or defaultBlendMode
  end
  return dc
end
