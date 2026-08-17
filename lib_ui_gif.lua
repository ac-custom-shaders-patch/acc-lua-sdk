__source 'lua/api_ui_gif.cpp'
__namespace 'ui'

require './common/internal_import'

-- GIF player

ffi.cdef [[
typedef struct {
  int _id;
  bool _required;
  bool _has_anything;
  bool _is_valid;
  bool keepRunning;
  const vec2 _resolution;
} gifholder;
]]

---@param source string|{width: number, height: number, decompress: boolean?, format: render.TextureFormat?} @URL, filename or binary data.
---@param simTime boolean? @Pass `true` to use simulation time (pause GIF when AC is paused), or `false` to use UI time. By default, `true` for car and track scripts.
---@return ui.GIFPlayer
function ui.GIFPlayer(source, simTime)
  if type(source) == 'table' and type(source.width) == 'number' and type(source.height) == 'number' then
    return ffi.gc(ffi.C.lj_gifholder_new__ui(__util.blob(__util.json(source)), -1), ffi.C.lj_gifholder_gc__ui)
  end
  return ffi.gc(ffi.C.lj_gifholder_new__ui(__util.blob(source), simTime ~= nil and (simTime and 2 or 1) or 0), ffi.C.lj_gifholder_gc__ui)
end

---GIF player can be used to display animated GIFs. Also supports regular and animated WEBP images.
---
---Also, it can be used to efficiently draw (or pass to a shader) any arbitrary data (GIF decoding happens on CPU, and for it, there is all this
---logic to efficiently push data from CPU to GPU — so why not let Lua, if needed, to instead push arbitrary data). For it, instead of a URL or
---a filename, pass a table to the constructor with `width` and `height`. This would create an empty image. Call `:push(data)`, and it’ll copy 
---passed data (could be a string, or, for example, a struct) to GPU. Add a field `decompress` set to `true`, and it’ll run `ac.decompress()` on
---that data first. Since CSP 0.3.0-preview466, you can also add a `format` field to specify a custom format (before that, it was always RGBA8888).
---Possible use cases:
---- A fast way to draw pixels directly (use `ac.StructItem.build()` to build a structure holding pixel data, update values and push them to the player);
---- An efficient way to pass a lot of data to a shader (these textures can be bound to shaders and accessed as textures, but they don’t have to store actual images); 
---- The simplest “video” streaming solution (if target resolution is small, an API endpoint can serve basic compressed binary data, and clients can
---repeatedly acquire it and push it here).
---@class ui.GIFPlayer
---@field keepRunning boolean @By default GIFs stop playing if they are not actively used in rendering. If you need them to keep running in background, set this property to `true`.
---@explicit-constructor ui.GIFPlayer
ffi.metatype('gifholder', {
  __tostring = function(s)
    return string.format('$ui.GIFPlayer://?id=%d', s._id)
  end,
  __index = {
    ---Get GIF resolution. If GIF is not yet loaded, returns zeroes.
    ---@return vec2 @Width and height in pixels.
    resolution = function(s)
      return s._resolution
    end,

    ---Push new bitmap data to a live-updating image. Doesn’t do anything if data is wrong size, or if player is not created for this mode.
    ---@param data binary
    ---@return boolean @Returns `false` if data doesn’t fit.
    push = function(s, data)
      return ffi.C.lj_gifholder_push__ui(s, __util.blob(data))
    end,

    ---Rewinds GIF back to beginning.
    ---
    ---Note: since 0.3.0.144, GIF players using the same source share their internal state, decoder and textures to save on RAM and
    ---CPU usage. Using this method on a shared player (if it’s played a bit) will disconnect the player and make it its own thing.
    ---@return ui.GIFPlayer @Returns itself for chaining several methods together.
    rewind = function(s)
      ffi.C.lj_gifholder_ctrl__ui(s, -1)
      return s
    end,

    ---Pauses playback. Added in 0.3.0.144.
    ---@return ui.GIFPlayer @Returns itself for chaining several methods together.
    pause = function(s)
      ffi.C.lj_gifholder_ctrl__ui(s, 0)
      return s
    end,

    ---Resumes playback. Added in 0.3.0.144.
    ---@return ui.GIFPlayer @Returns itself for chaining several methods together.
    resume = function(s)
      ffi.C.lj_gifholder_ctrl__ui(s, 1)
      return s
    end,

    ---Checks if GIF is loaded and ready to be drawn.
    ---@return boolean
    ready = function(s)
      if not s._has_anything then s._required = true end
      return s._has_anything
    end,

    ---Links playback rate to simulation speed: pauses when game or replay are paused, slows down with replay slow motion,
    ---speeds up with replay fast forwarding.
    ---@param value boolean? @Set to `true` to link playback rate.
    ---@return ui.GIFPlayer @Returns itself for chaining several methods together.
    linkToSimulationSpeed = function(s, value)
      __util.native('lj_gifholder_linktosimspeed', s, value ~= false)
      return s
    end,

    ---Returns `false` if GIF decoding has failed.
    ---@return boolean
    valid = function(s)
      return s._is_valid
    end
  }
})

__definitions()
