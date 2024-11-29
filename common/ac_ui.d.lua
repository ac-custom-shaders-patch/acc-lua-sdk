---UI namespace for creating custom widgets or drawing dynamic textures using IMGUI.
ui = {}

---Something that can be used as a texture, could be a texture filename, web URL, one of special values or an extra canvas, GIF or media player.
---If value starts with “%” and points to an icon in a DLL file, icon will be loaded (for scripts with full IO access only). Special values:
---- `color::X`: solid color texture (X can be three or four numbers or a hex representation).
---- `dynamic::…`: dynamic textures (require Graphics Adjustment to work, not very reliable in general but might work for some extra effects):
----  - `dynamic::screen`: LDR texture with scene contents.
----  - `dynamic::hdr`: HDR texture with scene contents.
----  - `dynamic::depth`: non-linear scene depth.
----  - `dynamic::noise`: general 32×32 noise texture.
---- `carN::…`: texture from a car with index N (0-based index), searches the same way car config would:
---  - `carN::dynamic::X`: car dynamic texture with a given key.
---  - `carN::car::X`: texture “X” from car KN5.
---  - `carN::special::driver`: driver icon (updates live for things like active voice chat).
---  - `carN::special::livery`: livery icon.
---  - `carN::special::theme`: theme image based on car livery color.
---  - Other values will look for an extension texture.
---- `track::…`: texture the track, searches the same way car config would:
---  - `track::track::X`: texture “X” from track KN5.
---  - Other values will look for an extension texture.
---@alias ui.ImageSource ui.ExtraCanvas|ui.SharedTexture|ui.GIFPlayer|ui.MediaPlayer|ac.GeometryShot|string|nil

---Very simple thing for smooth UI animations. Call it with a number for its initial state and it would
---return you a function. Each frame, call this function with your new target value and it would give you
---a smoothly changing numerical value. Unlike functions like `math.applyLag()`, this one is a bit more
---complicated, taking into account velocity as well.
---@param initialValue number @Initial value with which animation will start.
---@param weightMult number? @Weight multiplier for smoother or faster animation. Default value: 1.
---@return fun(target: number): number
function ui.SmoothInterpolation(initialValue, weightMult) end

---Another simple helper for easily creating elements fading in and out. Just pass it a draw callback and
---and initial state (should it be visible or not), and then call returned function every frame passing it
---a boolean to specify if item should be visible or not. Example:
---```
---local timeLeft = 120
---
---local function drawTimeLeft()
---  ui.text(string.format('Time left: %02.0f', math.max(0, timeLeft)))
---  -- keep in mind: when timer would reach 0, block would still be visible for a bit while fading out, so
---  -- that’s why there is that `math.max()` call
---end
---
---local fadingTimer = ui.FadingElement(drawTimeLeft)
---
---function script.update(dt)
---  timeLeft = timeLeft - dt
---  fadingTimer(timeLeft > 0 and timeLeft < 60)  -- only show timer if time left is below 60 seconds
---end
---```
---@param drawCallback fun() @Draw callback. Would only be called if alpha is above 0.2%, so there is no overhead if element is hidden.
---@param initialState boolean? @Should element be visible from the start. Default value: `false`.
---@return fun(state: boolean)
function ui.FadingElement(drawCallback, initialState) end

---@param filename string @Filename of a file to get the icon of. File might not exist, or it could only be a file extension.
---@param specialized boolean? @Set to `true` to try and get the icon for that exact file when possible. Usually just means it’ll look for exact icons of EXE files. Default value: `false`.
---@return ui.FileIcon
ui.FileIcon = function (filename, specialized) end

---Helper for drawing file icons.
---@class ui.FileIcon
local _uiFileIcon = {}

---Set icon style.
---@param style ui.FileIcon.Style
function _uiFileIcon:style(style) end

---@param name string @Name of the font, should be the name you can see when, for example, opening font with Windows Font Viewer (and not the name of the file). If your TTF file has a single font it in, you can use a path to it instead.
---@param dir string|nil @Optionally, path to a directory with TTF files in it. If provided, instead of looking for font in “content/fonts” and “extension/fonts”, CSP will scan given folder. Alternatively you can also use a path to a file here too, if you know for sure which file it’ll be (with TTF, different styles often go in different files).
---@return ui.DWriteFont
ui.DWriteFont = function (name, dir) end

---DirectWrite font name builder. Instead of using it, you can simply provide a string, but this thing might be a nicer way. You can chain its methods too:
---```
---local MyFavouriteFont = ui.DWriteFont('Best Font', './data'):weight(ui.DWriteFont.Weight.Bold):style(ui.DWriteFont.Style.Italic):stretch(ui.DWriteFont.Stretch.Condensed)
---…
---ui.pushFont(MyFavouriteFont)  -- you could also just put font here, but if defined once and reused, it would generate less garbage for GC to clean up.
---ui.dwriteText('Hello world!', 14)
---ui.popFont()
---```
---@class ui.DWriteFont
local _uiDWriteFont = {}

---Set font weight. Bold styles can be emulated even if there isn’t such font face, although quality of real font face would be better.
---@param weight ui.DWriteFont.Weight|integer @Alternatively, could be an integer in 1…999 range.
---@return self
function _uiDWriteFont:weight(weight) end

---Set font style. Italic style can be emulated even if there isn’t such font face, although quality of real font face would be better.
---@param style ui.DWriteFont.Style
---@return self
function _uiDWriteFont:style(style) end

---Set font stretch.
---@param stretch ui.DWriteFont.Stretch
---@return self
function _uiDWriteFont:stretch(stretch) end

---Set a custom axis value (available on Windows 10 Build 20348 or newer, otherwise values will be ignored).
---@param key 'weight'|'width'|'slant'|'opticalSize'|'italic'|string @Font variation table with list of keys is shown on https://fontdrop.info/.
---@param value number
---@return self
---@overload fun(s: ui.DWriteFont, values: {weight: number?, width: number?, slant: number?, opticalSize: number?, italic: number?}): self
function _uiDWriteFont:axis(key, value) end

---Disable font size rounding. Please use carefully: if you would to animate font size, it would quickly generate way too many atlases
---and increase both VRAM consumption and drawing time. If you need to animate font size, consider using `ui.beginScale()`/`ui.endScale()` instead.
---@param allow boolean? @Default value: `true`.
---@return self
function _uiDWriteFont:allowRealSizes(allow) end

---Allow or disallow use of colored emojis. If disabled, default black and white system glyphs will be drawn instead to system capabilities.
---Emoji are enabled by default.
---@param allow boolean? @Default value: `true`.
---@return self
function _uiDWriteFont:allowEmoji(allow) end

