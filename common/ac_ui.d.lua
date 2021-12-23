---Very simple thing for smooth UI animations. Call it with a number for its initial state and it would
---return you a function. Each frame, call this function with your new target value and it would give you
---a smoothly changing numerical value. Unlike functions like `math.applyLag()`, this one is a bit more
---complicated, taking into account velocity as well.
---@param initialValue number @Initial value with which animation will start.
---@param weightMult number @Weight multiplier for smoother or faster animation. Default value: 1.
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
---@param initialState boolean @Should element be visible from the start. Default value: `false`.
---@return fun(state: boolean)
function ui.FadingElement(drawCallback, initialState) end

---@param name string @Name of the font, should be the name you can see when, for example, opening font with Windows Font Viewer (and not the name of the file).
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
---@param weight ui.DWriteFont.Weight
function _uiDWriteFont:weight(weight)
  self._weight = weight
  self._fullName = nil
  return self
end

---Set font style. Italic style can be emulated even if there isn’t such font face, although quality of real font face would be better.
---@param style ui.DWriteFont.Style
function _uiDWriteFont:style(style)
  self._style = style
  self._fullName = nil
  return self
end

---Set font stretch.
---@param stretch ui.DWriteFont.Stretch
function _uiDWriteFont:stretch(stretch)
  self._stretch = stretch
  self._fullName = nil
  return self
end

---Disable font size rounding. Please use carefully: if you would to animate font size, it would quickly generate way too many atlases
---and increase both VRAM consumption and drawing time. If you need to animate font size, consider instead using `ui.beginScale()`/`ui.endScale()`.
function _uiDWriteFont:allowRealSizes()
  self._allowRealSizes = true
  self._fullName = nil
  return self
end