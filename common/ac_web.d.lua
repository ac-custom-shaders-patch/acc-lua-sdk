---@class WebResponse
---@field status integer
---@field headers table<string, string>
---@field body string
local _webResponse = {}

---Two possible ways to present payload: either as a string with data, or a table with a key `'filename'`.
---Second way can be used as a shortcut for `io.loadAsync()` (it loads data asyncronously).
---Data string can contain zeroes.
---@alias WebPayload string|{filename: string}
