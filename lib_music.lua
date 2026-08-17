__source 'lua/api_music.cpp'
__allow 'music'
require './common/internal_import'

ffi.cdef [[ 
typedef struct {
  lua_string_ref __cover_id;
  lua_string_ref __source_id;
  lua_string_ref __artist;
  lua_string_ref __album;
  lua_string_ref __title;
  const double playbackRate;
  const int albumTracksCount;
  const int trackNumber;
  const int trackDuration;
  const int trackPosition;
  const int __track_phase;
  const int __controls_flags;
  const char __data_phase;
  const bool isPlaying;
  const bool hasCover;
  const int8_t shuffleMode;
  const int8_t repeatMode;
  const int8_t playbackType;
  const int8_t playbackStatus;
} musicdata;
]]

local _cps
local _cpw

ffi.metatype('musicdata', {
  __tostring = function ()
    return _cpw.coverID
  end,
  __index = function (_, key)
    if key == 'title' then return _cpw.title end
    if key == 'album' then return _cpw.album end
    if key == 'artist' then return _cpw.artist end
    if key == 'sourceID' then return _cpw.sourceID end
    if key == 'coverID' then return _cpw.coverID end
  end,
  __newindex = function() error('This item is read-only', 2) end
})

__definitions()

return function()
  local first = _cps == nil
  if first then
    _cps = ffi.new('musicdata')
  end
  local r = ffi.C.lj_get_music_data__music(_cps, first)
  if first then
    _cpw = {title = '', album = '', artist = '', sourceID = '', coverID = __util.strrefr(_cps.__cover_id)}
  end
  if r == 2 then
    _cpw.title = __util.strrefr(_cps.__title)
    _cpw.album = __util.strrefr(_cps.__album)
    _cpw.artist = __util.strrefr(_cps.__artist)
    _cpw.sourceID = __util.strrefr(_cps.__source_id)
  end
  return _cps
end
