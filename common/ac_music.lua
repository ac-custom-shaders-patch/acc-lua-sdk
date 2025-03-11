---Syncs information about currently playing music and returns a table with details. Takes data from
---Windows 10 Media API, or from other sources configured in Music module of CSP.
---@return ac.MusicData
function ac.currentlyPlaying()
  ac.currentlyPlaying = __util.lazy('lib_music')
  return ac.currentlyPlaying()
end
