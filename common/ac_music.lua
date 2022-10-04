__source 'lua/api_music.cpp'
__allow 'music'

ffi.cdef [[ 
typedef struct {
  lua_string_ref __cover_id;
  lua_string_ref __source_id;
  lua_string_ref __artist;
  lua_string_ref __album;
  lua_string_ref __title;
  const int albumTracksCount;
  const int trackNumber;
  const int trackDuration;
  const int trackPosition;
  const int __track_phase;
  const char __data_phase;
  const bool isPlaying;
  const bool hasCover;
} musicdata;
]]

local _cps
local _cpw

ffi.metatype('musicdata', {
  __tostring = function () return _cpw.coverID end,
  __index = function (_, key)
    if key == 'title' then return _cpw.title end
    if key == 'album' then return _cpw.album end
    if key == 'artist' then return _cpw.artist end
    if key == 'sourceID' then return _cpw.sourceID end
  end,
  __newindex = function() error('This item is read-only', 2) end
})

---Syncs information about currently playing music and returns a table with details. Takes data from
---Windows 10 Media API, or from other sources configured in Music module of CSP.
---@return ac.MusicData
function ac.currentlyPlaying()
  if _cps == nil then
    _cps = ffi.new('musicdata')
    _cpw = {}
  end
  local r = ffi.C.lj_get_music_data__music(_cps)
  if r == 2 or _cpw.title == nil then
    _cpw.title = __util.strrefr(_cps.__title)
    _cpw.album = __util.strrefr(_cps.__album)
    _cpw.artist = __util.strrefr(_cps.__artist)
    _cpw.sourceID = __util.strrefr(_cps.__source_id)
  end
  if _cpw.coverID == nil then
    _cpw.coverID = __util.strrefr(_cps.__cover_id)
  end
  return _cps
end
