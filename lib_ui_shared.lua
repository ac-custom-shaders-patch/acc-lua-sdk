__source 'lua/api_ui_shared.cpp'
__namespace 'ui'

require './common/internal_import'

-- Shared textures

ffi.cdef [[
typedef struct {
  uint64_t _handle;
  int _id;
  int __rc;
  const vec2 _resolution;
  bool _has_anything;
} sharedtex;
]]

---@param handle integer @Shared texture handle. Can be either a `D3D11_RESOURCE_MISC_SHARED` handle or a handle from `:sharedHandle()` of an extra canvas.
---@param ntMode nil|integer|boolean? @Set to `true` if the handle is NT handle. Alternatively, set to an integer with source process ID. Default value: `false`. Note: for NT handles it’s better to use the named textures and pass it as a string instead (with the overload).
---@return ui.SharedTexture
---@overload fun(name: string) @Overload using name of a shared NT texture, works a lot better.
function ui.SharedTexture(handle, ntMode)
  local s
  if type(handle) == 'string' then
    s = ffi.C.lj_sharedtex_newnamed__ui(handle)
  elseif ntMode then
    s = ffi.C.lj_sharedtex_new__ui(tonumber(handle) or 0, true, ntMode ~= true and tonumber(ntMode) or 0)
  else
    s = ffi.C.lj_sharedtex_new__ui(tonumber(handle) or 0, false, 0)
  end
  return ffi.gc(s, ffi.C.lj_sharedtex_gc__ui)
end

---A wrapper for accessing textures shared by other Lua scripts or even by other applications. For the latter, textures need to have `D3D11_RESOURCE_MISC_SHARED` flag and be on the same GPU.
---@class ui.SharedTexture
---@explicit-constructor ui.SharedTexture
ffi.metatype('sharedtex', {
  __tostring = function(s)
    return string.format('$ui.SharedTexture://?id=%d', s._id)
  end,
  __index = {
    ---Dispose texture and release its view. Call this method if remote texture is being destroyed.
    dispose = ffi.C.lj_sharedtex_dispose__ui,

    ---Sets texture name for debugging. Textures with set name appear in Lua Debug App, allowing to monitor their state.
    ---@param name string? @Name to display texture as. If set to `nil` or `false`, name will be reset and texture will be hidden.
    ---@return self @Returns itself for chaining several methods together.
    setName = function(s, name)
      ffi.C.lj_sharedtex_setname__ui(s, name and tostring(name) or nil)
      return s
    end,

    ---Get texture handle used for creating a texture. If texture has failed to load, returns 0. If texture is loaded by name and loaded properly, returns 1.
    ---@return integer
    handle = function(s)
      return s._handle
    end,

    ---Get texture resolution. If texture has failed to load, returns zeroes.
    ---@return vec2 @Width and height in pixels.
    resolution = function(s)
      return s._resolution
    end,

    ---Returns `false` if access to a shared texture has failed.
    ---@return boolean
    valid = function(s)
      return s._has_anything
    end,
  }
})

__definitions()
