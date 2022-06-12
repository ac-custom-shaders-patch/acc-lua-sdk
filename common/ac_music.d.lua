---Information about currently playing track. Use function `ac.currentlyPlaying()` to get
---a reference to it.
---
---To draw album cover, pass `ac.MusicData` as an argument to something like `ui.image()`.
---@class ac.MusicData
---@field isPlaying boolean @If `true`, music is currently playing.
---@field hasCover boolean @If `true`, album cover is present.
---@field title string @Name of currently playing track.
---@field album string @Name of currently playing album (if not available, an empty string).
---@field artist string @Name of currently playing artist (if not available, an empty string).
---@field sourceID string @Source ID from where track is coming from. To draw an icon for it, pass it as Icon24 ID. You can check if there is an icon using `ui.isKnownIcon24(playing.sourceID)`.
---@field albumTracksCount integer @Number of tracks in current album, or 0 if value is not available.
---@field trackNumber integer @1-based track number in current album, or 0 if value is not available.
---@field trackDuration integer @Track duration in seconds, or -1 if value is not available.
---@field trackPosition integer @Track position in seconds, or -1 if value is not available.
local _musicData = {}

