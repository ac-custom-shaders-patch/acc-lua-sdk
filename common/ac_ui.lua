__source 'lua/api_ui.cpp'
__source 'lua/api_ui_ac.cpp'
__source 'lua/api_ui_gif.cpp'
__source 'lua/api_ui_shared.cpp'
__namespace 'ui'

require './ac_render_shader'
require './ac_ui_enums'

local _sp_uiu = {template = 'ui.fx', defaultBlendMode = render.BlendMode.Opaque, delayed = true}
local _sp_uif = {template = 'fullscreen.fx', defaultBlendMode = render.BlendMode.Opaque}
local _sp_uid = {template = 'direct.fx', defaultBlendMode = render.BlendMode.Opaque}

local weatherIcons = {
  [ac.WeatherType.LightThunderstorm] = ui.Icons.WeatherLightThunderstorm,
  [ac.WeatherType.Thunderstorm] = ui.Icons.WeatherThunderstorm,
  [ac.WeatherType.HeavyThunderstorm] = ui.Icons.WeatherHeavyThunderstorm,
  [ac.WeatherType.LightDrizzle] = ui.Icons.WeatherLightDrizzle,
  [ac.WeatherType.Drizzle] = ui.Icons.WeatherDrizzle,
  [ac.WeatherType.HeavyDrizzle] = ui.Icons.WeatherHeavyDrizzle,
  [ac.WeatherType.LightRain] = ui.Icons.WeatherLightRain,
  [ac.WeatherType.Rain] = ui.Icons.WeatherRain,
  [ac.WeatherType.HeavyRain] = ui.Icons.WeatherHeavyRain,
  [ac.WeatherType.LightSnow] = ui.Icons.WeatherLightSnow,
  [ac.WeatherType.Snow] = ui.Icons.WeatherSnow,
  [ac.WeatherType.HeavySnow] = ui.Icons.WeatherHeavySnow,
  [ac.WeatherType.LightSleet] = ui.Icons.WeatherLightSleet,
  [ac.WeatherType.Sleet] = ui.Icons.WeatherSleet,
  [ac.WeatherType.HeavySleet] = ui.Icons.WeatherHeavySleet,
  [ac.WeatherType.Clear] = ui.Icons.WeatherClear,
  [ac.WeatherType.FewClouds] = ui.Icons.WeatherFewClouds,
  [ac.WeatherType.ScatteredClouds] = ui.Icons.WeatherScatteredClouds,
  [ac.WeatherType.BrokenClouds] = ui.Icons.WeatherBrokenClouds,
  [ac.WeatherType.OvercastClouds] = ui.Icons.WeatherOvercastClouds,
  [ac.WeatherType.Fog] = ui.Icons.WeatherFog,
  [ac.WeatherType.Mist] = ui.Icons.WeatherMist,
  [ac.WeatherType.Smoke] = ui.Icons.WeatherSmoke,
  [ac.WeatherType.Haze] = ui.Icons.WeatherHaze,
  [ac.WeatherType.Sand] = ui.Icons.WeatherSand,
  [ac.WeatherType.Dust] = ui.Icons.WeatherDust,
  [ac.WeatherType.Squalls] = ui.Icons.WeatherSqualls,
  [ac.WeatherType.Tornado] = ui.Icons.WeatherTornado,
  [ac.WeatherType.Hurricane] = ui.Icons.WeatherHurricane,
  [ac.WeatherType.Cold] = ui.Icons.WeatherCold,
  [ac.WeatherType.Hot] = ui.Icons.WeatherHot,
  [ac.WeatherType.Windy] = ui.Icons.WeatherWindy,
  [ac.WeatherType.Hail] = ui.Icons.WeatherHail,
}

---Returns an icon for a given weather type
---@param weatherType ac.WeatherType
---@return ui.Icons
function ui.weatherIcon(weatherType)
  return weatherIcons[weatherType] or ui.Icons.WeatherClear
end

---Push style variable.
---@param varID ui.StyleVar
---@param value number|vec2
function ui.pushStyleVar(varID, value)
  if type(value) == 'number' then
    ffi.C.lj_pushStyleVar_v1__ui(varID, value)
  else
    ffi.C.lj_pushStyleVar_v2__ui(varID, __util.ensure_vec2(value))
  end
end

---Push ID (use it if you, for example, have a list of buttons created in a loop).
---@param value number|string
function ui.pushID(value)
  if type(value) == 'number' then
    ffi.C.lj_pushID_num__ui(value)
  else
    ffi.C.lj_pushID_string__ui(__util.str(value))
  end
end

local __itep = refbool()

---Text input control. Returns updated string (which would be the input string unless it changed, so no)
---copying there. Second return value would change to `true` when text has changed. Example:
---```
---myText = ui.inputText('Enter something:', myText)
---```
---
---Third value returned is `true` if Enter was pressed while editing text.
---@param label string
---@param str string
---@param flags ui.InputTextFlags?
---@param size vec2? @If specified, text input is multiline.
---@return string
---@return boolean
---@return boolean
function ui.inputText(label, str, flags, size)
  local changed = ffi.C.lj_inputText_inner__ui(__util.str(label), __util.str(str), tonumber(flags) or 0, __itep, __util.ensure_vec2_nil(size))
  if changed == nil then return str, false, __itep.value end
  return ffi.string(changed), true, __itep.value
end

---Color picker control. Returns true if color has changed (as usual with Lua, colors are passed)
---by reference so update value would be put in place of old one automatically.
---@param label string
---@param color rgb|rgbm
---@param flags ui.ColorPickerFlags?
---@return boolean
function ui.colorPicker(label, color, flags)
  if rgb.isrgb(color) then
    return ffi.C.lj_colorPicker_rgb__ui(__util.str(label), color, tonumber(flags) or 0)
  elseif rgbm.isrgbm(color) then
    return ffi.C.lj_colorPicker_rgbm__ui(__util.str(label), color, tonumber(flags) or 0)
  else
    error('Unsupported type for color picker: '..color, 2)
  end
end

---Color button control. Returns true if color has changed (as usual with Lua, colors are passed)
---by reference so update value would be put in place of old one automatically.
---@param label string
---@param color rgb|rgbm
---@param flags ui.ColorPickerFlags?
---@param size vec2?
---@return boolean
function ui.colorButton(label, color, flags, size)
  if rgb.isrgb(color) then
    return ffi.C.lj_colorButton_rgb__ui(__util.str(label), color, tonumber(flags) or 0, __util.ensure_vec2(size))
  elseif rgbm.isrgbm(color) then
    return ffi.C.lj_colorButton_rgbm__ui(__util.str(label), color, tonumber(flags) or 0, __util.ensure_vec2(size))
  else
    error('Unsupported type for color picker: '..color, 2)
  end
end

---Show popup message.
---@param icon ui.Icons
---@param message string
---@param undoCallback fun()|nil @If provided, there’ll be an undo button which, when clicked, will call this callback.
function ui.toast(icon, message, undoCallback)
  if undoCallback == nil then
    ffi.C.lj_toast_inner__ui(__util.str(icon), __util.str(message), 0)
  else
    ffi.C.lj_toast_inner__ui(__util.str(icon), __util.str(message), __util.expectReply(function (arg)
      if arg then
        undoCallback()
      end
    end))
  end
end

---Draw a window with transparent background.
---@generic T
---@param id string @Window ID, has to be unique within your script.
---@param pos vec2 @Window position.
---@param size vec2 @Window size.
---@param noPadding boolean? @Disables window padding. Default value: `false`.
---@param inputs boolean? @Enables inputs (buttons and such). Default value: `false`.
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(id: string, pos: vec2, size: vec2, content: fun())
---@overload fun(id: string, pos: vec2, size: vec2, noPadding: boolean, content: fun())
function ui.transparentWindow(id, pos, size, noPadding, inputs, content)
  if type(noPadding) == 'function' then content, noPadding, inputs = noPadding, nil, nil end
  if type(inputs) == 'function' then content, inputs = inputs, nil end
  ui.beginTransparentWindow(id, pos, size, noPadding == true, inputs == true)
  return using(content, ui.endTransparentWindow)
end

---Draw a window with semi-transparent background.
---@generic T
---@param id string @Window ID, has to be unique within your script.
---@param pos vec2 @Window position.
---@param size vec2 @Window size.
---@param noPadding boolean? @Disables window padding. Default value: `false`.
---@param inputs boolean? @Enables inputs (buttons and such). Default value: `false`.
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(id: string, pos: vec2, size: vec2, content: fun())
---@overload fun(id: string, pos: vec2, size: vec2, noPadding: boolean, content: fun())
function ui.toolWindow(id, pos, size, noPadding, inputs, content)
  if type(noPadding) == 'function' then content, noPadding, inputs = noPadding, nil, nil end
  if type(inputs) == 'function' then content, inputs = inputs, nil end
  ui.beginToolWindow(id, pos, size, noPadding == true, inputs == true)
  return using(content, ui.endToolWindow)
end

---Draw a tooltip with custom content.
---@generic T
---@param padding vec2? @Tooltip padding. Default value: `vec2(20, 8)`.
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(content: fun())
function ui.tooltip(padding, content)
  if type(padding) == 'function' then padding, content = nil, padding end
  ui.beginTooltip(padding)
  return using(content, ui.endTooltip)
end

local function endThinScrollbarChild()
  ui.thinScrollbarEnd()
  ui.endChild()
end

---Draw a child window: perfect for clipping content, for scrolling lists, etc. Think of it more like
---a HTML div with overflow set to either scrolling or hidden, for example.
---@generic T
---@param id string @Window ID, has to be unique within given context (like, two sub-windows of the same window should have different IDs).
---@param size vec2 @Window size.
---@param border boolean? @Window border.
---@param flags ui.WindowFlags? @Window flags.
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(id: string, size: vec2, border: boolean, content: fun())
---@overload fun(id: string, size: vec2, content: fun())
function ui.childWindow(id, size, border, flags, content)
  if content == nil then flags, content = content, flags end
  if content == nil then border, content = content, border end
  if content == nil then size, content = content, size end
  if flags == nil and (__mode__ == 'track_scriptable_display' or __mode__ == 'car_scriptable_display') then
    flags = bit.bor(ui.WindowFlags.NoScrollbar, ui.WindowFlags.NoBackground)
  end
  local thinScrollbar = type(flags) == 'number' and bit.band(flags, ui.WindowFlags.ThinScrollbar) ~= 0
  if thinScrollbar then
    flags = bit.bor(bit.bxor(flags, ui.WindowFlags.ThinScrollbar), ui.WindowFlags.NoScrollbar)
  end
  if ui.beginChild(id, size, border, flags) then
    if thinScrollbar then
      ui.thinScrollbarBegin(true)
      return using(content, endThinScrollbarChild)
    else
      return using(content, ui.endChild)
    end
  else
    ui.endChild()
  end
end

---Draw a tree node element: a collapsible block with content inside it (which might include other tree
---nodes). Great for grouping things together. Note: if you need to have a tree node with changing label,
---use label like “your changing label###someUniqueID” for it to work properly. Everything after “###” will
---count as ID and not be shown. Same trick applies to other controls as well, such as tabs, buttons, etc.
---@generic T
---@param label string @Tree node label (which also acts like its ID).
---@param flags ui.TreeNodeFlags? @Tree node flags.
---@param content fun(): T @Tree node content callback (called only if tree node is expanded).
---@return T
---@overload fun(label: string, content: fun())
function ui.treeNode(label, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTreeNode(label, flags) then
    return using(content, ui.endTreeNode)
  end
end

---Draw a section with tabs. Inside, use `ui.tabItem()` to draw actual tabs like so:
---```
---ui.tabBar('someTabBarID', function ()
---  ui.tabItem('Tab 1', function () --[[ Contents of Tab 1 ]] end)
---  ui.tabItem('Tab 2', function () --[[ Contents of Tab 2 ]] end)
---end)
---```
---@generic T
---@param id string @Tab bar ID.
---@param flags ui.TabBarFlags? @Tab bar flags.
---@param content fun(): T @Individual tabs callback.
---@return T
---@overload fun(id: string, content: fun())
function ui.tabBar(id, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTabBar(id, flags) then
    return using(content, ui.endTabBar)
  end
end

---Draw a new tab in a tab bar. Note: if you need to have a tab with changing label,
---use label like “your changing label###someUniqueID” for it to work properly. Everything after “###” will
---count as ID and not be shown. Same trick applies to other controls as well, such as tree nodes, buttons, etc.
---```
---ui.tabBar('someTabBarID', function ()
---  ui.tabItem('Tab 1', function () --[[ Contents of Tab 1 ]] end)
---  ui.tabItem('Tab 2', function () --[[ Contents of Tab 2 ]] end)
---end)
---```
---@generic T
---@param label string @Tab label.
---@param flags ui.TabItemFlags? @Tab flags.
---@param content fun(): T @Tab content callback (called only if tab is selected).
---@return T
---@overload fun(label: string, content: fun())
function ui.tabItem(label, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTabItem(label, flags) then
    return using(content, ui.endTabItem)
  end
end

---Adds context menu to previously drawn item which would open when certain mouse button would be pressed. Once it happens,
---content callback will be called each frame to draw contents of said menu.
---```
---ui.itemPopup(ui.MouseButton.Right, function ()
---  if ui.selectable('Item 1') then --[[ Item 1 was clicked ]] end
---  if ui.selectable('Item 2') then --[[ Item 2 was clicked ]] end
---  ui.separator()
---  if ui.selectable('Item 3') then --[[ Item 3 was clicked ]] end
---  -- Other types of controls would also work
---end)
---```
---@generic T
---@param id string @Context menu ID.
---@param mouseButton ui.MouseButton @Mouse button
---@param content fun(): T @Menu content callback (called only if menu is opened).
---@return T
---@overload fun(id: string, content: fun())
---@overload fun(mouseButton: ui.MouseButton, content: fun())
---@overload fun(content: fun())
function ui.itemPopup(id, mouseButton, content)
  if type(id) == 'function' then id, mouseButton, content = '', 1, id end
  if type(mouseButton) == 'function' then id, mouseButton, content = type(id) == 'number' and '' or id, type(id) == 'number' and id or 1, mouseButton end
  if ui.beginPopupContextItem(id, mouseButton) then
    return using(content, ui.endPopup)
  end
end

---Adds a dropdown list (aka combo box). Items are drawn in content callback function, or alternatively
---it can work with a list of strings and an ID of a selected item, returning either ID of selected item and
---boolean with `true` value if it was changed, or if ID is a refnumber, it would just return a boolean value
---for whatever it was changed or not.
---@generic T
---@param label string @Label of the element.
---@param previewValue string? @Preview value.
---@param flags ui.ComboFlags? @Combo box flags.
---@param content fun(): T? @Combo box items callback.
---@return T
---@overload fun(label: string, previewValue: string?, content: fun())
---@overload fun(label: string, selectedIndex: integer, flags: ui.ComboFlags, content: string[]): integer, boolean
---@overload fun(label: string, selectedIndex: refnumber, flags: ui.ComboFlags, content: string[]): boolean
function ui.combo(label, previewValue, flags, content)
  if content == nil then flags, content = content, flags end
  if content == nil then previewValue, content = content, previewValue end

  if type(content) == 'function' then
    if ui.beginCombo(label, previewValue, flags) then
      return using(content, ui.endCombo)
    end
  elseif type(content) == 'table' then
    if type(previewValue) == 'number' then
      local changed = false
      if ui.beginCombo(label, content[previewValue], flags) then
        using(function ()
          for i = content[0] and 0 or 1, #content do
            if ui.selectable(content[i], i == previewValue) and i ~= previewValue then
              previewValue = i
              changed = true
            end
          end
        end, ui.endCombo)
      end
      return previewValue, changed
    elseif refnumber.isrefnumber(previewValue) then
      local changed = false
      if ui.beginCombo(label, content[previewValue.value], flags) then
        using(function ()
          for i = 1, #content do
            if ui.selectable(content[i], i == previewValue.value) and i ~= previewValue.value then
              previewValue.value = i
              changed = true
            end
          end
        end, ui.endCombo)
      end
      return changed
    else
      error('With list of items, second value should be either a number of a selected item or a refnumber', 2)
    end
  end
end

local _rn = refnumber()

---Adds a slider. For value, either pass `refnumber` and slider would return a single boolean with `true` value
---if it was moved (and storing updated value in passed `refnumber`), or pass a regular number and then
---slider would return number and then a boolean. Example:
---```
----- With refnumber:
---local ref = refnumber(currentValue)
---if ui.slider('Test', ref) then currentValue = ref.value end
---
----- Without refnumber:
---local value, changed = ui.slider('Test', currentValue)
---if changed then currentValue = value end
---
----- Or, of course, if you don’t need to know if it changed (and, you can always use `ui.itemEdited()` as well):
---currentValue = ui.slider('Test', currentValue)
---```
---I personally prefer to hide slider label and instead use its format string to show what’s it for. IMGUI would
---not show symbols after “##”, but use them for ID calculation.
---```
---currentValue = ui.slider('##someSliderID', currentValue, 0, 100, 'Quantity: %.0f')
---```
---By the way, a bit of clarification: “##” would do
---that, but “###” would result in ID where only symbols going after “###” are taken into account. Helps if you
---have a control which label is constantly changing. For example, a tab showing a number of elements or current time.
---
---To enter value with keyboard, hold Ctrl and click on it.
---@param label string @Slider label.
---@param value refnumber|number @Current slider value.
---@param min number? @Default value: 0.
---@param max number? @Default value: 1.
---@param format string|'%.3f'|nil @C-style format string. Default value: `'%.3f'`.
---@param power number|boolean|nil @Power for non-linear slider. Default value: `1` (linear). Pass `true` to enable integer mode instead.
---@return number @Possibly updated slider value.
---@return boolean @True if slider has moved.
---@overload fun(label: string, value: number, min: number, max: number, format: string, power: number): number, boolean
function ui.slider(label, value, min, max, format, power)
  if power == true then
    power = -1
  end

  if refnumber.isrefnumber(value) then
    return ffi.C.lj_slider_inner__ui(__util.str(label), value, tonumber(min) or 0, tonumber(max) or 100, __util.str_opt(format) or "%.3f", tonumber(power) or 1)
  end

  _rn.value = tonumber(value) or 0
  local changed = ffi.C.lj_slider_inner__ui(__util.str(label), _rn, tonumber(min) or 0, tonumber(max) or 100, __util.str_opt(format) or "%.3f", tonumber(power) or 1)
  return _rn.value, changed
end

local function smoothInterpolation(value, speed, target, dt)
  if dt >= 0.1 or math.abs(value - target) < 0.0001 then
    return target, 0
  elseif dt > 0 then
    for _ = 1, 10 do
      local lag1 = 0.98
      local lag2 = 0.6
      local dir = target - value
      local lag = lag1 + (lag2 - lag1) * speed * speed
      local delta = dir * math.lagMult(lag, dt / 10)
      local localSpeed = math.saturate(10 * (delta / dt) / dir)
      speed = math.lerp(localSpeed, speed, 1 / (1 + dt * 4))
      value = value + delta
    end
  end
  return value, speed
end

ui.SmoothInterpolation = class(function (initialValue, weightMult) return { value = initialValue, speed = 0, dtMult = 1 / (weightMult or 1) } end, class.Minimal, class.NoInitialize)

function ui.SmoothInterpolation:__call(target)
  self.value, self.speed = smoothInterpolation(self.value, self.speed, target, ac.getUI().dt * self.dtMult)
  return self.value
end

ui.FadingElement = class(function (drawCallback, initialState) return { value = ui.SmoothInterpolation(initialState and 1 or 0), draw = drawCallback } end, class.Minimal, class.NoInitialize)

function ui.FadingElement:__call(state)
  local alpha = self.value(state and 1 or 0)
  if alpha > 0.002 then
    ffi.C.lj_pushStyleVar_v1__ui(ui.StyleVar.Alpha, alpha)
    local err_ = nil
    try(self.draw, function (err) err_ = err end)
    ffi.C.lj_popStyleVar__ui(1)
    if err_ ~= nil then
      error(err_, 2)
    end
  end
end

ui.FileIcon = class('ui.FileIcon', function (filename, specialized)
  specialized = specialized and string.sub(filename, #filename - 3, #filename):lower() == '.exe'
  filename = specialized and filename or string.match(filename, '.[^.]*$')
  return {
    _filename = filename,
    _style = 'L'
  }
end, class.NoInitialize)

ui.FileIcon.Style = __enum({}, {
  Small = 'S',
  Large = 'L',
})

function ui.FileIcon:style(style)
  self._style = style
  return self
end

function ui.FileIcon:__tostring()
  return '%fileIcon:'..self._style..self._filename
end

ui.DWriteFont = class('ui.DWriteFont', function (name, dir)
  local fullName = dir and string.format('%s:%s', name, dir) or name
  return {
    _baseName = fullName,
    _fullName = fullName
  }
end, class.NoInitialize)

ui.DWriteFont.Weight = __enum({}, {
  Thin = 'Thin',              --- Thin (100).
  UltraLight = 'UltraLight',  --- Ultra-light (200).
  Light = 'Light',            --- Light (300).
  SemiLight = 'SemiLight',    --- Semi-light (350).
  Regular = 'Regular',        --- Regular (400).
  Medium = 'Medium',          --- Medium (500).
  SemiBold = 'SemiBold',      --- Semi-bold (600).
  Bold = 'Bold',              --- Bold (700).
  UltraBold = 'UltraBold',    --- Ultra-bold (800).
  Black = 'Black',            --- Black (900).
  UltraBlack = 'UltraBlack'   --- Ultra-black (950).
})

ui.DWriteFont.Style = __enum({}, {
  Normal = 'Normal',    --- Charachers are upright in most fonts.
  Italic = 'Italic',    --- In italic style, characters are truly slanted and appear as they were designed.
  Oblique = 'Oblique',  --- With oblique style characters are artificially slanted.
})

ui.DWriteFont.Stretch = __enum({}, {
  UltraCondensed = 'UltraCondensed',
  ExtraCondensed = 'ExtraCondensed',
  Condensed = 'Condensed',
  SemiCondensed = 'SemiCondensed',
  Medium = 'Medium',
  SemiExpanded = 'SemiExpanded',
  Expanded = 'Expanded',
  ExtraExpanded = 'ExtraExpanded',
  UltraExpanded = 'UltraExpanded',
})

function ui.DWriteFont:weight(weight)
  self._weight = weight
  self._fullName = nil
  return self
end

function ui.DWriteFont:style(style)
  self._style = style
  self._fullName = nil
  return self
end

function ui.DWriteFont:stretch(stretch)
  self._stretch = stretch
  self._fullName = nil
  return self
end

function ui.DWriteFont:allowRealSizes(allow)
  self._allowRealSizes = allow ~= false
  self._fullName = nil
  return self
end

function ui.DWriteFont:allowEmoji(allow)
  self._allowEmoji = allow ~= false
  self._fullName = nil
  return self
end

local _fontTable = {}

function ui.DWriteFont:__tostring()
  local ret = self._fullName
  if not ret then
    local t = _fontTable
    table.clear(t)

    t[1] = self._baseName
    local n = 1

    local weight = self._weight
    if weight then t[n + 1], t[n + 2], n = ';Weight=', weight, n + 2 end

    local style = self._style
    if style then t[n + 1], t[n + 2], n = ';Style=', style, n + 2 end

    local stretch = self._stretch
    if stretch then t[n + 1], t[n + 2], n = ';Stretch=', stretch, n + 2 end

    if self._allowRealSizes then t[n + 1] = ';AnyFontSize' end
    if self._allowEmoji == false then t[n + 1] = ';NoEmoji' end

    ret = table.concat(t, '')
    self._fullName = ret
  end
  return ret
end

---Draws race flag of a certain type, or in a certain color in its usual position.
---Use it if you want to add a new flag type: this way, if custom UI later would replace flags with
---a different look (or even if it’s just a custom texture mod), it would still work.
---
---Note: if your script can access physics and you need a regular flag, using `physics.overrideRacingFlag()`
---would work better (it would also affect track conditions and such).
---@param color ac.FlagType|rgbm
function ui.drawRaceFlag(color)
  local p1 = vec2(15, 15)
  if ac.getSim().isTripleMode then
    p1.x = p1.x + ac.getUI().windowSize.x / 3
  end
  local p2 = vec2(p1.x + 150, p1.y + 80)
  local flag
  if type(color) == 'number' then
    if color == ac.FlagType.Start then flag, color = '/content/gui/flags/whiteFlag.png', rgbm.colors.green
    elseif color == ac.FlagType.Caution then flag, color = '/content/gui/flags/yellowFlag.png', rgbm.colors.white
    elseif color == ac.FlagType.Slippery then flag, color = '/extension/textures/flags/slippery.png', rgbm.colors.white
    elseif color == ac.FlagType.PitLaneClosed then return
    elseif color == ac.FlagType.Stop then flag, color = '/content/gui/flags/blackFlag_small.png', rgbm.colors.white
    elseif color == ac.FlagType.SlowVehicle then flag, color = '/content/gui/flags/whiteFlag.png', rgbm(0.8, 0.8, 0.8, 1)
    elseif color == ac.FlagType.Ambulance then flag, color = '/extension/textures/flags/ambulance.png', rgbm.colors.white
    elseif color == ac.FlagType.ReturnToPits then flag, color = '/content/gui/flags/penalty.png', rgbm.colors.white
    elseif color == ac.FlagType.MechanicalFailure then flag, color = '/extension/textures/flags/mechanical_failure.png', rgbm.colors.white
    elseif color == ac.FlagType.Unsportsmanlike then flag, color = '/extension/textures/flags/unsportsmanlike.png', rgbm.colors.white
    elseif color == ac.FlagType.StopCancel then return
    elseif color == ac.FlagType.FasterCar then flag, color = '/content/gui/flags/blueFlag.png', rgbm.colors.white
    elseif color == ac.FlagType.Finished then flag, color = '/content/gui/flags/finish.png', rgbm.colors.white
    elseif color == ac.FlagType.OneLapLeft then flag, color = '/content/gui/flags/whiteFlag.png', rgbm.colors.white
    elseif color == ac.FlagType.SessionSuspended then flag, color = '/content/gui/flags/whiteFlag.png', rgbm.colors.red
    elseif color == ac.FlagType.Code60 then flag, color = '/extension/textures/flags/code60.png', rgbm.colors.white
    else return end
  else
    flag = '/content/gui/flags/whiteFlag.png'
  end
  ui.drawImage(ac.getFolder(ac.FolderID.Root)..flag, p1, p2, color)
end

---Draws icon for car state, along with low fuel icon. If more than one icon is visible at once, subsequent ones are drawn
---to the right of previous icon. Settings altering position and opacity of low fuel icon also apply here. Background is
---included by default: simply pass a semi-transparent symbol here.
---@param iconID ui.Icons|fun(iconSize: number) @Might be an icon ID or anything else `ui.icon()` can take, or a function taking icon size.
---@param color rgbm? @Icon tint for background. Default value: `rgbm.colors.white`.
function ui.drawCarIcon(iconID, color)
  local pos = vec2()
  local size = vec2()
  local opacity = ffi.C.lj_draw_car_icon__ui(pos, size)
  if opacity > 0 then
    local color4 = color and rgbm.new(color) or rgbm.colors.white
    color4.mult = color4.mult * opacity
    ui.drawImage('extension/textures/gui/car_indicator_bg.png', pos, pos + size, color4)
    local cur = ui.getCursor()
    if type(iconID) == 'function' then
      local curNew = pos + size / 2 - 18
      ui.setCursor(curNew)
      ui.pushClipRect(curNew, curNew + 36)
      iconID(36)
      ui.popClipRect()
    else
      ui.setCursor(pos)
      ui.icon(iconID, size, rgbm(0, 0, 0, opacity), 24)
    end
    ui.setCursor(cur)
  end
end

---Generates ID to use with `ui.icon()` to draw an icon from an atlas.
---@param filename string @Texture filename.
---@param uv1 vec2 @UV coordinates of the upper left corner.
---@param uv2 vec2 @UV coordinates of the bottom right corner.
---@return ui.Icons @Returns an ID to be used as an argument for `ui.icon()` function.
function ui.atlasIconID(filename, uv1, uv2)
  return string.format('at:%s\n%s,%s,%s,%s', filename,
    vec2.isvec2(uv1) and uv1.x or tonumber(uv1) or 0, vec2.isvec2(uv1) and uv1.y or tonumber(uv1) or 0,
    vec2.isvec2(uv2) and uv2.x or tonumber(uv2) or 1, vec2.isvec2(uv2) and uv2.y or tonumber(uv2) or 1)
end

---Generates a table acting like icons atlas.
---@generic T
---@param filename string @Texture filename.
---@param columns integer @Number of columns in the atlas.
---@param rows integer @Number of rows in the atlas.
---@param icons T @Table with icons from left top corner, each icon is a table with 1-based row and column indices.
---@return T
function ui.atlasIcons(filename, columns, rows, icons)
  return table.map(icons, function (coords, key)
    local itemX = coords[2] - 1
    local itemY = coords[1] - 1
    return ui.atlasIconID(filename, vec2(itemX / columns, itemY / rows), vec2((itemX + 1) / columns, (itemY + 1) / rows)), key
  end)
end

ffi.cdef [[ 
typedef struct {
  mat4x4 transform;
  float pitch;
  float camera_interior_mult;
  float camera_exterior_mult;
  float camera_track_mult;
  float within_range;
} _mmfholder_extradata;

typedef struct {
  int _id;
  int _pad;
  _mmfholder_extradata* _extra;
  void* _mmf;
} mmfholder;
]]

--[[? if (!ctx.flags.withoutAudio && ctx.ldoc) out(]]

---Checks if system supports these media players (Microsoft Media Foundation framework was added in Windows 8). If it’s not supported,
---you can still use API, but it would fail to load any video or audio.
---@return boolean
function ui.MediaPlayer.supported() end

---@param source string|nil @URL or a filename. Optional, can be set later with `player:setSource()`.
--[[@tableparam audioParams nil|{
  rawOutput: boolean = nil "Set to `true` to output audio directly, without FMOD (won’t respect AC audio device selection or stop when AC is paused)",
  reverbResponse: boolean = false "Set to `true` to get audio to react to reverb",
  use3D: boolean = false "Set to `true` to load audio without any 3D effects (if not set, car display scripts have it as `true` by default and update position based on screen position, but only them)",
  insideConeAngle: number = nil "Angle in degrees at which audio is at 100% volume",
  outsideConeAngle: number = nil "Angle in degrees at which audio is at `outsideVolume` volume",
  outsideVolume: number = nil "Volume multiplier if listener is outside of the cone",
  minDistance: number = nil "Distance at which audio would stop going louder as it approaches listener (default is 1)",
  maxDistance: number = nil "Distance at which audio would attenuating as it gets further away from listener (default is 10 km)",
  dopplerEffect: number = nil "Scale for doppler effect"
} ]]
---@return ui.MediaPlayer
function ui.MediaPlayer(source, audioParams) end

--[[) ?]]
--[[? if (!ctx.flags.withoutAudio) out(]]

ui.MediaPlayer = setmetatable({
  supported = ffi.C.lj_mmfholder_supported__ui,
  supportedAsync = function(callback) return ffi.C.lj_mmfholder_supportedasync__ui(__util.expectReply(callback)) end
}, { 
  __call = function (_, source, audioParams) 
    local r = ffi.gc(ffi.C.lj_mmfholder_new__ui(audioParams and __util.json(audioParams)), ffi.C.lj_mmfholder_gc__ui)
    if source ~= nil then r:setSource(source) end
    return r
  end 
})

local _mmfac

---Media player which can load a video and be used as a texture in calls like `ui.drawImage()`, `ui.beginTextureShade()` or `display.image()`. Also, it can load an audio
---file and play it offscreen.
---
---Since 0.1.77, media players can also be used as textures for scene references, like `ac.findMeshes(…):setMaterialTexture()`.
---
---Uses Microsoft Media Foundation framework for video decoding and hardware acceleration, so only supports codecs supported by Windows.
---Instead of asking user to install custom codecs, it might be a better idea to use [ones available by default](https://support.microsoft.com/en-us/windows/codecs-faq-392483a0-b9ac-27c7-0f61-5a7f18d408af).
---
---Usage:
---```
---local player = ui.MediaPlayer()
---player:setSource('myVideo.wmw'):setAutoPlay(true)
---
---function script.update(dt)
---  ui.drawImage(player, vec2(), vec2(400, 200))
---end
---```
---
---When first used, MMF library is loaded and a separate DirectX device is created. Usually this process is pretty much instantaneous,
---but sometimes it might take a few seconds. During that time you can still use media player methods to set source, volume, start playback, etc.
---Some things might act a bit differently though. To make sure library is loaded before use, you can use `ui.MediaPlayer.supportedAsync()` with
---a callback.
---@class ui.MediaPlayer
---@explicit-constructor ui.MediaPlayer
ffi.metatype('mmfholder', { 
  __tostring = function (s) return string.format('$ui.MediaPlayer://?id=%d', s._id) end,
  __index = {
    ---Checks if system supports these media players (Microsoft Media Foundation framework was added in Windows 8). If it’s not supported,
    ---you can still use API, but it would fail to load any video or audio.
    ---
    ---Instead of this one, use `ui.MediaPlayer.supportedAsync()` which wouldn’t cause game to freeze while waiting for MMF to finish
    ---initializing.
    ---@deprecated
    ---@return boolean
    supported = function() return ffi.C.lj_mmfholder_supported__ui() end,

    ---Checks if system supports these media players (Microsoft Media Foundation framework was added in Windows 8). If it’s not supported,
    ---you can still use API, but it would fail to load any video or audio. Runs asyncronously.
    ---@param callback fun(supported: boolean)
    supportedAsync = function(callback) return ffi.C.lj_mmfholder_supportedasync__ui(__util.expectReply(callback)) end,

    ---Get an audio event corresponding with with media player. Disposing this one, as well as playback controls, won’t have any effect.
    ---(Actually this isn’t real `ac.AudioEvent`, but it should be compatible. Can’t do a real one because underlying FMOD channel might
    ---change when the source changes.)
    ---
    ---For backwards compatibility, these audio events have `cameraInteriorMultiplier` set to `1` by default.
    ---@return ac.AudioEvent
    audio = function (s)
      if s._extra.within_range < 0 then error('FMOD integration is not available this player', 2) end
      if not _mmfac then 
        _mmfac = {
          c = setmetatable({inAutoLoopMode = false}, {__mode = 'kv'}),
          f = {
            keepAlive = ac.skipSaneChecks,
            setParam = ac.skipSaneChecks,
            setDistanceMin = ac.skipSaneChecks,
            setDistanceMax = ac.skipSaneChecks,
            setConeSettings = ac.skipSaneChecks,
            setDSPParameter = ac.skipSaneChecks,
            dispose = ac.skipSaneChecks,
            resume = ac.skipSaneChecks,
            resumeIf = ac.skipSaneChecks,
            stop = ac.skipSaneChecks,
            start = ac.skipSaneChecks,
            isValid = function (s)
              return s._owner:hasAudio()
            end,
            isWithinRange = function (s)
              return s._extra.within_range == 1
            end,
            isPlaying = function (s)
              return s._owner:playing()
            end,
            isPaused = function (s)
              return not s._owner:playing()
            end,
            setPosition = function (s, pos, dir, up, vel)
              ffi.C.lj_mmfholder_setpos__ui(s._owner, __util.ensure_vec3(pos), __util.ensure_vec3_nil(dir), __util.ensure_vec3_nil(up), __util.ensure_vec3(vel))
              return s
            end,
            getTransformationRaw = function (s) return s._owner._extra.transform end,
          },
          m = {
            __index = function (s, key)
              if key == 'volume' then 
                return s._owner:volume()
              elseif key == 'pitch' then 
                return s._owner._extra.pitch
              elseif key == 'cameraInteriorMultiplier' then 
                return s._owner._extra.camera_interior_mult
              elseif key == 'cameraExteriorMultiplier' then 
                return s._owner._extra.camera_exterior_mult
              elseif key == 'cameraTrackMultiplier' then 
                return s._owner._extra.camera_track_mult
              else
                return _mmfac.f[key]
              end
            end,
            __newindex = function (s, key, value)
              if key == 'volume' then 
                s._owner:setVolume(value)
              elseif key == 'pitch' then 
                s._owner._extra.pitch = value
              elseif key == 'cameraInteriorMultiplier' then 
                s._owner._extra.camera_interior_mult = value
              elseif key == 'cameraExteriorMultiplier' then 
                s._owner._extra.camera_exterior_mult = value
              elseif key == 'cameraTrackMultiplier' then 
                s._owner._extra.camera_track_mult = value
              end
            end,
          }
        }
      end
      local r = _mmfac.c[s]
      if not r then
        r = setmetatable({_owner = s}, _mmfac.m)
        _mmfac.c[s] = r
      end
      return r
    end,

    ---Sets file name or URL for video player to play. URL can lead to a remote resource.
    ---@param url string @URL or a filename.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setSource = function (s, url)
      ffi.C.lj_mmfholder_setsource__ui(s, url ~= nil and tostring(url) or nil)
      return s
    end,

    ---Get video resolution. Would not work right after initialization or `player:setSource()`, first video needs to finish loading.
    ---@return vec2 @Width and height in pixels.
    resolution = ffi.C.lj_mmfholder_getresolution__ui,

    ---Get current playback position in seconds. Can be changed with `player:setCurrentTime()`.
    ---@return number
    currentTime = ffi.C.lj_mmfholder_getcurrenttime__ui,

    ---Get video duration in seconds.
    ---@return number
    duration = ffi.C.lj_mmfholder_getduration__ui,

    ---Get current video volume in range between 0 and 1. Can be changed with `player:setVolume()`.
    ---@return number
    volume = ffi.C.lj_mmfholder_getvolume__ui,

    ---Get current video pitch. Can be changed with `player:setPitch()`.
    ---@return number
    pitch = ffi.C.lj_mmfholder_getpitch__ui,

    ---Get current video audio balance in range between -1 (left channel only) and 1 (right channel only). Can be changed with `player:setBalance()`.
    ---@return number
    balance = ffi.C.lj_mmfholder_getbalance__ui,

    ---Get current playback speed. Normal speed is 1. Can be changed with `player:setPlaybackRate()`.
    ---@return number
    playbackRate = ffi.C.lj_mmfholder_getplaybackrate__ui,

    ---Get available time in seconds. If you are streaming a video, it might be a good idea to pause it until there would be enough of time available to play it.
    ---Note: sometimes might misbehave when combined with jumping to a future point in video.
    ---@return number
    availableTime = ffi.C.lj_mmfholder_getavailabletime__ui,

    ---Checks if video is playing now. Can be changed with `player:play()` and `player:pause()`.
    ---@return boolean
    playing = ffi.C.lj_mmfholder_getplaying__ui,

    ---Checks if video is looping. Can be changed with `player:setLooping()`.
    ---@return boolean
    looping = ffi.C.lj_mmfholder_getlooping__ui,

    ---Checks if video would be played automatically. Can be changed with `player:setAutoPlay()`.
    ---@return boolean
    autoPlay = ffi.C.lj_mmfholder_getautoplay__ui,

    ---Checks if video is muted. Can be changed with `player:setMuted()`.
    ---@return boolean
    muted = ffi.C.lj_mmfholder_getmuted__ui,

    ---Checks if video has ended.
    ---@return boolean
    ended = ffi.C.lj_mmfholder_getended__ui,

    ---Checks if video player is seeking currently.
    ---@return boolean
    seeking = ffi.C.lj_mmfholder_getseeking__ui,

    ---Checks if video is ready. If MMF failed to load the video, it would return `false`.
    ---@return boolean
    hasVideo = ffi.C.lj_mmfholder_gethasvideo__ui,

    ---Checks if there is an audio to play.
    ---@return boolean
    hasAudio = ffi.C.lj_mmfholder_gethasaudio__ui,

    ---Sets video position.
    ---@param value number @New video position in seconds.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setCurrentTime = function (s, value) ffi.C.lj_mmfholder_setcurrenttime__ui(s, tonumber(value) or 0) return s end,

    ---Sets playback speed.
    ---@param value number? @New speed value from 0 to 1. Default value: 1.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setPlaybackRate = function (s, value) ffi.C.lj_mmfholder_setplaybackrate__ui(s, tonumber(value) or 1) return s end,
    
    ---Sets volume.
    ---@param value number? @New volume value from 0 to 1. Default value: 1.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setVolume = function (s, value) ffi.C.lj_mmfholder_setvolume__ui(s, tonumber(value) or 1) return s end,
    
    ---Sets pitch. Available only with FMOD audio.
    ---@param value number? @New pitch value. Default value: 1.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setPitch = function (s, value) ffi.C.lj_mmfholder_setpitch__ui(s, tonumber(value) or 1) return s end,
    
    ---Sets audio balance.
    ---@param value number? @New balance value from -1 (left channel only) to 1 (right channel only). Default value: 0.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setBalance = function (s, value) ffi.C.lj_mmfholder_setbalance__ui(s, tonumber(value) or 0) return s end,

    ---Sets muted parameter.
    ---@param value boolean? @Set to `true` to disable audio.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setMuted = function (s, value) ffi.C.lj_mmfholder_setmuted__ui(s, value ~= false) return s end,

    ---Sets looping parameter.
    ---@param value boolean? @Set to `true` if video needs to start from beginning when it ends.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setLooping = function (s, value) ffi.C.lj_mmfholder_setlooping__ui(s, value ~= false) return s end,

    ---Sets auto playing parameter.
    ---@param value boolean? @Set to `true` if video has to be started automatically.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setAutoPlay = function (s, value) ffi.C.lj_mmfholder_setautoplay__ui(s, value ~= false) return s end,

    ---Sets MIP maps generation flag. Use it if you want to tie media resource directly to a mesh instead of using it
    ---in UI or scriptable display.
    ---
    ---MIP maps are additional copies of the texture with half resolution, quarter resolution, etc. If in distance, GPUs
    ---would read those downscaled copies instead of main texture to both avoid aliasing and improve performance.
    ---@param value boolean? @Set to `true` to generate MIP maps.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setGenerateMips = function (s, value) ffi.C.lj_mmfholder_setgeneratemips__ui(s, value ~= false) return s end,

    ---If you’re using a video element in UI or a scriptable display, this method would not do anything. But if you’re
    ---tying media to a mesh (with, for example, `ac.findMeshes():setMaterialTexture()`), this method allows to control
    ---how much time is passed before video is updated to the next frame. Default value: 0.05 s for 20 FPS. Set to 0
    ---to update video every frame (final framerate would still be limited by frame rate of original video).
    ---@param period number? @Update period in seconds. Default value: 0.05.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setUpdatePeriod = function (s, period) ffi.C.lj_mmfholder_setupdateperiod__ui(s, tonumber(period) or 0.05) return s end,

    ---Links playback rate to simulation speed: pauses when game or replay are paused, slows down with replay slow motion,
    ---speeds up with replay fast forwarding.
    ---@param value boolean? @Set to `true` to link playback rate.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    linkToSimulationSpeed = function (s, value) ffi.C.lj_mmfholder_linktosim__ui(s, value ~= false) return s end,

    ---Sets media element to be used as texture by calling these functions:
    ---```
    ---self:setAutoPlay(true)            -- start playing once video is ready
    ---self:setMuted(true)               -- without audio (it wouldn’t be proper 3D audio anyway)
    ---self:setLooping(true)             -- start from the beginning once it ends
    ---self:setGenerateMips(true)        -- generate MIPs to avoid aliasing in distance
    ---self:linkToSimulationSpeed(true)  -- pause when game or replay are paused, etc.
    ---```
    ---Of course, you can call those functions manually, or call this one and then use any other functions
    ---to change the behaviour. It’s only a helping shortcut, that’s all.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    useAsTexture = function (s) return s:setAutoPlay(true):setMuted(true):setLooping(true):setGenerateMips(true):linkToSimulationSpeed(true) end,

    ---Starts to play a video.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    play = function (s) ffi.C.lj_mmfholder_play__ui(s) return s end,

    ---Pauses a video. To fully stop it, use `player:pause():setCurrentTime(0)`.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    pause = function (s) ffi.C.lj_mmfholder_pause__ui(s) return s end,

    ---Some debug information for testing and fixing things.
    ---@return string
    debugText = function (s) return __util.strrefr(ffi.C.lj_mmfholder_debugtext__ui(s)) end,
  }
})

--[[) ?]]

ffi.cdef [[ 
typedef struct { int _id; } uirt;
typedef struct { int _something; } uirtcpu;
]]

---@param resolution vec2|integer @Resolution in pixels. Usually textures with sizes of power of two work the best.
---@param mips integer? @Number of MIPs for a texture. MIPs are downsized versions of main texture used to avoid aliasing. Default value: 1 (no MIPs).
---@param antialiasingMode render.AntialiasingMode? @Antialiasing mode. Default value: `render.AntialiasingMode.None` (disabled).
---@param textureFormat render.TextureFormat? @Texture format. Default value: `render.TextureFormat.R8G8B8A8.UNorm`.
---@param flags render.TextureFlags? @Extra flags. Default value: `0`.
---@return ui.ExtraCanvas
---@overload fun(resolution: vec2|integer, mips: integer, textureFormat: render.TextureFormat)
function ui.ExtraCanvas(resolution, mips, antialiasingMode, textureFormat, flags)
  if type(resolution) == 'number' then resolution = vec2(resolution, resolution)
  elseif not vec2.isvec2(resolution) then error('Resolution is required', 2) 
  else resolution = resolution:clone() end
  resolution.x = math.clamp(math.ceil(resolution.x), 1, 8192)
  resolution.y = math.clamp(math.ceil(resolution.y), 1, 8192)

  if flags == nil and antialiasingMode and antialiasingMode > 0 and antialiasingMode < 100 then
    antialiasingMode, textureFormat = textureFormat, antialiasingMode
  end

  return ffi.gc(ffi.C.lj_uirt_new__ui(resolution.x, resolution.y, tonumber(mips) or 1, tonumber(antialiasingMode) or 0,
    tonumber(textureFormat) or 28, tonumber(flags) or 0), ffi.C.lj_uirt_gc__ui)
end

---@alias ui.GaussianBlurKernelSize 7|15|23|35|63|127

---Extra canvases are textures you can use in UI calls instead of filenames or apply as material textures to scene geometry,
---and also edit them live by drawing things into them using “ui…” functions. A few possible use cases as an example:
---- If your app or display uses a complex background or another element, it might be benefitial to draw it into a texture once and then reuse it;
---- If you want to apply some advanced transformations to some graphics, it might work better to use texture;
---- It can also be used to blur some elements by drawing them into a texture and then drawing it blurred.
---
---Note: update happens from a different short-lived UI context, so interactive controls would not work here.
---@class ui.ExtraCanvas
---@explicit-constructor ui.ExtraCanvas
ffi.metatype('uirt', { 
  __tostring = function (s) return string.format('$ui.ExtraCanvas://?id=%d', s._id) end,
  __index = {
    ---Disposes canvas and releases resources.
    dispose = function (s)
      return ffi.C.lj_uirt_dispose__ui(s)
    end,

    ---Sets canvas name for debugging. Canvases with set name appear in Lua Debug App, allowing to monitor their state.
    ---@param name string? @Name to display texture as. If set to `nil` or `false`, name will be reset and texture will be hidden.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    setName = function (s, name)
      ffi.C.lj_uirt_setname__ui(s, name and tostring(name) or nil)
      return s
    end,

    ---Updates texture, calling `callback` to draw things with. If you want to do several changes, it would work better to group them in a
    ---single `canvas:update()` call.
    ---
    ---Note: canvas won’t be cleared here, to clear it first, use `canvas:clear()` method.
    ---@param callback fun(dt: number) @Drawing function. Might not be called if canvas has been disposed or isn’t available for drawing into.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    update = function (s, callback)
      local dt = ffi.C.lj_uirt_begin__ui(s)
      if dt == -2 then error('Canvas is already being updated', 2) end
      if dt >= 0 then
        __util.pushEnsureToCall(function () ffi.C.lj_uirt_end__ui(s) end)
        callback(dt)
        __util.popEnsureToCall()
      end
      return s
    end,

    ---Updates texture using a shadered quad. Faster than using `:update()` with `ui.renderShader()`:
    ---no time will be wasted setting up IMGUI pass and preparing all that data, just a single draw call.
    ---Shader is compiled at first run, which might take a few milliseconds.
    ---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
    ---while drawing will be skipped until shader is ready.
    ---
    ---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
    ---it a very effective tool for any custom drawing you might need to make.
    ---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
    --[[@tableparam params {
      p1: vec2 = nil "Position of upper left corner relative to whole screen or canvas. Default value: `vec2(0, 0)`.",
      p2: vec2 = nil "Position of bottom right corner relative to whole screen or canvas. Default value: size of canvas.",
      uv1: vec2 = nil "Texture coordinates for upper left corner. Default value: `vec2(0, 0)`.",
      uv2: vec2 = nil "Texture coordinates for bottom right corner. Default value: `vec2(1, 1)`.",
      blendMode: render.BlendMode = nil "Blend mode. Default value: `render.BlendMode.Opaque`.",
      async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
      cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
      defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
      textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
      values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",      
      directValuesExchange: boolean = nil "If you’re reusing table between calls instead of recreating it each time and pass `true` as this parameter, `values` table will be swapped with an FFI structure allowing to skip data copying step and achieve the best performance. Note: with this mode, you’ll have to transpose matrices manually.",
      shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
    }]]
    updateWithShader = function (s, params)
      if not ffi.C.lj_uicshader_runoncanvas0__ui(s) then return false end
      local dc = __util.setShaderParams2(params, _sp_uid)
      if dc then 
        ffi.C.lj_uicshader_runoncanvas1__ui(s, dc, __util.ensure_vec2_nil(params.p1), __util.ensure_vec2_nil(params.p2), 
          __util.ensure_vec2_nil(params.uv1), __util.ensure_vec2_nil(params.uv2))
      else
        ffi.C.lj_uicshader_restorert__ui()
      end
      return dc ~= nil
    end,

    ---Updates texture using a shader with a fullscreen pass. Faster than using `:update()` with `ui.renderShader()`:
    ---no time will be wasted setting up IMGUI pass and preparing all that data, just a single draw call.
    ---Shader is compiled at first run, which might take a few milliseconds.
    ---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
    ---while drawing will be skipped until shader is ready.
    ---
    ---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
    ---it a very effective tool for any custom drawing you might need to make.
    ---
    ---Unlike `:updateWithShader()`, this version is single pass stereo-aware and can be used in the middle of
    ---rendering scene, and has access to camera state and some rendering pipeline textures by default (see “fullscreen.fx” template).
    ---Use it if you need to prepare an offscreen buffer to apply to the scene.
    ---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
    --[[@tableparam params {
      p1: vec2 = nil "Position of upper left corner relative to whole screen or canvas. Default value: `vec2(0, 0)`.",
      p2: vec2 = nil "Position of bottom right corner relative to whole screen or canvas. Default value: size of canvas.",
      uv1: vec2 = nil "Texture coordinates for upper left corner. Default value: `vec2(0, 0)`.",
      uv2: vec2 = nil "Texture coordinates for bottom right corner. Default value: `vec2(1, 1)`.",
      blendMode: render.BlendMode = nil "Blend mode. Default value: `render.BlendMode.Opaque`.",
      async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
      cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
      defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
      textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
      values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",      
      directValuesExchange: boolean = nil "If you’re reusing table between calls instead of recreating it each time and pass `true` as this parameter, `values` table will be swapped with an FFI structure allowing to skip data copying step and achieve the best performance. Note: with this mode, you’ll have to transpose matrices manually.",
      shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
    }]]
    updateSceneWithShader = function (s, params)
      if not ffi.C.lj_uicshader_runoncanvas_fullscreen0__ui(s) then return false end
      local dc = __util.setShaderParams2(params, _sp_uif)
      if dc then 
        ffi.C.lj_uicshader_runoncanvas_fullscreen1__ui(s, dc)
      else
        ffi.C.lj_uicshader_restorert__ui()
      end
      return dc ~= nil
    end,

    ---Clears canvas.
    ---@param col rgbm
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    clear = function(s, col)
      ffi.C.lj_uirt_clear__ui(s, __util.ensure_rgbm(col))
      return s
    end,

    ---Manually applies antialiasing to the texture (works only if it was created with a specific antialiasing mode).
    ---By default antialiasing is applied automatically, but calling this function switches AA to a manual mode.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    applyAntialiasing = function(s)
      ffi.C.lj_uirt_applyaa__ui(s)
      return s
    end,

    ---Generates MIPs. Once called, switches texture to manual MIPs generating mode. Note: this operation is not that expensive, but it’s not free.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    mipsUpdate = function(s)
      ffi.C.lj_uirt_mips__ui(s)
      return s
    end,

    ---Overrides exposure used if antialiasing mode is set to YEBIS value. By default scene exposure is used.
    ---@param value number? @Exposure used by YEBIS post-processing. Pass `nil` to reset to default behavior.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    setExposure = function(s, value)
      ffi.C.lj_uirt_setyebisparams__ui(s, tonumber(value) or math.huge)
      return s
    end,

    ---Saves canvas as an image.
    ---@param filename string @Destination filename.
    ---@param format ac.ImageFormat|nil @Texture format (by default guessed based on texture name).
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    save = function(s, filename, format)
      if not filename or type(filename) ~= 'string' or #filename == '' then return end
      if format == nil then
        local ext = string.sub(filename, #filename - 3, #filename):lower()
        if ext == '.png' then format = ac.ImageFormat.PNG 
        elseif ext == '.dds' then format = ac.ImageFormat.DDS
        elseif ext == '.zip' then format = ac.ImageFormat.ZippedDDS
        elseif ext == '.bmp' then format = ac.ImageFormat.BMP
        else format = ac.ImageFormat.JPG end
      end
      ffi.C.lj_uirt_save__ui(s, filename, format)
      return s
    end,

    ---Returns image encoded in DDS format. Might be useful if you would need to store an image
    ---in some custom form (if so, consider compressing it with `ac.compress()`).
    ---
    ---Note: you can later use `ui.decodeImage()` to get a string which you can then pass as a texture name
    ---to any of texture receiving functions. This way, you can load image into a new canvas later: just
    ---create a new canvas (possibly using `ui.imageSize()` first to get image size) and update it drawing
    ---imported image to the full size of the canvas.
    ---@return string|nil @Binary data, or `nil` if binary data export has failed.
    encode = function(s)
      return __util.strrefp(ffi.C.lj_uirt_tobytes__ui(s))
    end,

    ---Returns texture resolution (or zeroes if element has been disposed).
    ---@return vec2
    size = function(s)
      return ffi.C.lj_uirt_size__ui(s)
    end,

    ---Returns number of MIP maps (1 for no MIP maps and it being a regular texture).
    ---@return integer
    mips = function(s)
      return ffi.C.lj_uirt_mipscount__ui(s)
    end,

    ---Returns shared handle to the texture. Shared handle can be used in other scripts with `ui.SharedTexture()`, or, if `crossProcess` flag
    ---is set to `true`, also accessed by other processes.
    ---@param crossProcess boolean? @Set to `true` to be able to pass a handle to other processes. Requires `render.TextureFlags.Shared` flag to be set during creation. Default value: `false`.
    ---@return integer
    sharedHandle = function(s, crossProcess)
      return ffi.C.lj_uirt_sharedhandle__ui(s, crossProcess == true)
    end,

    ---Clones current canvas.
    ---@return ui.ExtraCanvas @Returns new canvas.
    clone = function (s)
      local res = s:size()
      if res.x == 0 then error('Can’t clone disposed canvas', 2) end
      return ui.ExtraCanvas(res, s:mips()):copyFrom(s)
    end,

    ---Backup current state of canvas, return a function which can be called to restore original state. Note:
    ---it clones current canvas texture, so don’t make too many backup copies at once.
    ---@return fun() @Returns function which will restore original canvas state when called. Function can be called more than once.
    backup = function (s)
      local res = s:size()
      if res.x == 0 then
        return function(cmd)
          if cmd == 'memoryFootprint' then return 0 end
          if cmd == 'update' then return s:backup() end
        end
      end
      local copy
      s:accessData(function (err, data)
        if err then ac.error('Failed to backup ui.ExtraCanvas: '..tostring(err)) end
        if data then copy = data:compress() end
      end)
      return function(cmd)
        if cmd == 'memoryFootprint' then return copy and copy:memoryFootprint() or 0 end
        if cmd == 'update' then return s:backup() end
        if cmd == 'dispose' then if copy then copy:dispose() end return end
        if copy then s:copyFrom(copy) end
      end
    end,

    ---Copies contents from another canvas, CPU canvas data, image or an icon. Faster than copying by drawing. If source is disposed or missing,
    ---does not alter the contents of the canvas.
    ---@param other ui.ExtraCanvas|ui.ExtraCanvasData|ui.Icons @Canvas to copy content from.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    copyFrom = function(s, other)
      if ffi.istype('uirt*', other) then ffi.C.lj_uirt_copyfrom__ui(s, other)
      elseif ffi.istype('uirtcpu*', other) then ffi.C.lj_uirt_fromcpu__ui(s, other)
      else ffi.C.lj_uirt_copyfromtex__ui(s, tostring(other)) end
      return s;
    end,

    ---Fills with canvas with blurred version of another texture, applying two optimized gaussian blur passes.
    ---@param other ui.ImageSource @Canvas to copy content from.
    ---@param kernelSize ui.GaussianBlurKernelSize? @Kernel size. Default value: 63.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    gaussianBlurFrom = function(s, other, kernelSize)
      ffi.C.lj_uirt_blurgaussianfromtex__ui(s, tostring(other), tonumber(kernelSize) or 63)
      return s;
    end,

    ---Downloads data from GPU to CPU asyncronously (usually takes about 0.15 ms to get the data). Resulting data can be
    ---used to access colors of individual pixels or upload it back to CPU restoring original state.
    ---@param callback fun(err: string, data: ui.ExtraCanvasData)
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    accessData = function (s, callback)
      if not callback then return end
      if type(callback) ~= 'function' then error('Function is required for callback', 2) end
      ffi.C.lj_uirt_tocpu__ui(s, __util.expectReply(function (err, key)
        if err then callback(err)
        else
          local r = ffi.C.lj_uirtcpu_get__ui(key)
          if r == nil then callback('Unexpectedly missing data') 
          else callback(nil, ffi.gc(r, ffi.C.lj_uirtcpu_gc__ui)) end
        end
      end))
      return s;
    end
  }
})

---Contents of `ui.ExtraCanvas` copied to CPU. There, that data can no longer be used to draw things (but it can be uploaded
---back to GPU with `canvas:copyFrom()`), but it can be used to quickly access colors of individual pixels. Unlike `ui.ExtraCanvas`,
---instances of `ui.ExtraCanvasData` consume RAM, not VRAM.
---
---To save RAM while storing several copies of data, you can use `data:compress()` to apply fast LZ4 compression. Note that each time
---you would use data by reading colors of pixels, data would get decompressed automatically. Copying extra data back to canvas with
---`canvas:copyFrom()` works with both compressed and decompressed data (data would be decompressed temporary).
---@class ui.ExtraCanvasData
ffi.metatype('uirtcpu', {
  __index = {
    ---Disposes canvas and releases resources.
    dispose = function (s)
      return ffi.C.lj_uirtcpu_dispose__ui(s)
    end,

    ---Compresses data using LZ4 algorithm if data wasn’t compressed already.
    ---@return ui.ExtraCanvasData @Returns itself for chaining several methods together.
    compress = function(s)
      ffi.C.lj_uirtcpu_compress__ui(s)
      return s
    end,

    ---Returns original texture resolution (or zeroes if data has been disposed).
    ---@return vec2
    size = function(s)
      return ffi.C.lj_uirtcpu_size__ui(s)
    end,

    ---Returns `true` if data is currently compressed.
    ---@return boolean
    compressed = function(s)
      return ffi.C.lj_uirtcpu_compressed__ui(s)
    end,

    ---Returns space taken by data in bytes.
    ---@return integer
    memoryFootprint = function(s)
      return ffi.C.lj_uirtcpu_datasize__ui(s)
    end,

    ---Returns numeric value of a pixel of R32FLOAT texture. If coordinates are outside, or data has been disposed, returns zeroes.
    ---@param x integer @0-based X coordinate.
    ---@param y integer @0-based Y coordinate.
    ---@return number @Pixel color from 0 to 1.
    ---@overload fun(s: ui.ExtraCanvasData, pos: vec2): number
    floatValue = function(s, x, y)
      if vec2.isvec2(x) then x, y = x.x, x.y end
      return ffi.C.lj_uirtcpu_float__ui(s, tonumber(x) or 0, tonumber(y) or 0)
    end,

    ---Returns color of a pixel of RGBA8888 texture. If coordinates are outside, or data has been disposed, returns zeroes.
    ---@param x integer @0-based X coordinate.
    ---@param y integer @0-based Y coordinate.
    ---@return rgbm @Pixel color from 0 to 1.
    ---@overload fun(s: ui.ExtraCanvasData, pos: vec2): rgbm
    color = function(s, x, y)
      local r = rgbm()
      if vec2.isvec2(x) then x, y = x.x, x.y end
      ffi.C.lj_uirtcpu_colorto__ui(s, r, tonumber(x) or 0, tonumber(y) or 0)
      return r
    end,

    ---Writes color of a pixel to a provided `rgbm` value. Same as `data:color()`, but does not create new color values, so should be
    ---easier on garbage collector and more useful if you need to go through a lot of pixels for some reason.
    ---@param color rgbm @0-based X coordinate.
    ---@param x integer @0-based X coordinate.
    ---@param y integer @0-based Y coordinate.
    ---@return rgbm @Pixel color from 0 to 1 (same as input `color`).
    ---@overload fun(s: ui.ExtraCanvasData, color: rgbm, pos: vec2): rgbm
    colorTo = function(s, color, x, y)
      if not rgbm.isrgbm(color) then error('Color is required', 2) end
      if vec2.isvec2(x) then x, y = x.x, x.y end
      ffi.C.lj_uirtcpu_colorto__ui(s, color, math.floor(tonumber(x)) or 0, math.floor(tonumber(y)) or 0)
      return color
    end,
  }
})

local _uiState, _simState

local _scmt = {
  __call = function (s, withRepeat)
    if _uiState.wantCaptureKeyboard or not _simState.isWindowForeground then return false end
    for i = 1, #s do
      local j = s[i]
      if type(j) == 'number' then 
        return not _uiState.ctrlDown and not _uiState.shiftDown and not _uiState.altDown and not _uiState.superDown and ui.keyboardButtonPressed(j, withRepeat)
      end
      if ui.keyboardButtonPressed(j.key, withRepeat)
          and (j.ctrl == true) == _uiState.ctrlDown
          and (j.shift == true) == _uiState.shiftDown
          and (j.alt == true) == _uiState.altDown
          and (j.super == true) == _uiState.superDown then
        return true
      end
    end
    return false
  end,
  __index = {
    down = function(s)
      if _uiState.wantCaptureKeyboard or not _simState.isWindowForeground then return false end
      for i = 1, #s do
        local j = s[i]
        if type(j) == 'number' then 
          return not _uiState.ctrlDown and not _uiState.shiftDown and not _uiState.altDown and not _uiState.superDown and ui.keyboardButtonDown(j)
        end
        if ui.keyboardButtonDown(j.key)
            and (j.ctrl == true) == _uiState.ctrlDown
            and (j.shift == true) == _uiState.shiftDown
            and (j.alt == true) == _uiState.altDown
            and (j.super == true) == _uiState.superDown then
          return true
        end
      end
      return false
    end
  }
}

---Returns a function which returns `true` when keyboard shortcut is pressed.
--[[@tableparam key {key: ui.KeyIndex = ui.KeyIndex.A, ctrl: boolean, alt: boolean = nil, shift: boolean = nil, super: boolean = nil} ]]
---@return fun(withRepeat: boolean|nil): boolean
---@overload fun(key: ui.KeyIndex|integer, ...): function
function ui.shortcut(key, ...)
  if not _uiState then _uiState, _simState = ac.getUI(), ac.getSim() end
  local k = {key, ...}
  if #k == 0 then return function() return false end end
  return setmetatable(k, _scmt)
end

---Draws image using custom drawcall (not an IMGUI drawcall). Any transformations and color shifts
---wouldn’t work. But there are some extra shading features available here.
--[[@tableparam params {
  filename: string "Path to the image, absolute or relative to script folder or AC root. URLs are also accepted.",
  p1: vec2 = vec2(0, 0) "Position of upper left corner relative to whole screen or canvas.",
  p2: vec2 = vec2(1, 1) "Position of bottom right corner relative to whole screen or canvas.",
  color: rgbm = rgbm.colors.white "Tint of the image, with white it would be drawn as it is. In this call, can be above 0. Default value: `rgbm.colors.white`.",
  colorOffset: rgbm = nil "Color offset. Default value: `rgbm.colors.transparent`.",
  uv1: vec2 = vec2(0, 0) "Texture coordinates for upper left corner. Default value: `vec2(0, 0)`.",
  uv2: vec2 = vec2(1, 1) "Texture coordinates for bottom right corner. Default value: `vec2(1, 1)`.",
  blendMode: render.BlendMode = render.BlendMode.BlendAccurate "Blend mode. Default value: `render.BlendMode.BlendAccurate`.",
  mask1: string = nil "Optional mask #1, resulting image will be drawn only if mask is non-transparent and with non-zero alpha channel. Default value: `nil`.",
  mask1UV1: vec2 = nil "Texture coordinates for upper left corner of a mask. Default value: `vec2(0, 0)`.",
  mask1UV2: vec2 = nil "Texture coordinates for bottom right corner of a mask. Default value: `vec2(1, 1)`.",
  mask1Flags: render.TextureMaskFlags = nil "Flags for the first mask. Default value: 6.",
  mask2: string = nil "Optional mask #2, resulting image will be drawn only if mask is non-transparent and with non-zero alpha channel. Default value: `nil`.",
  mask2UV1: vec2 = nil "Texture coordinates for upper left corner of a mask. Default value: `vec2(0, 0)`.",
  mask2UV2: vec2 = nil "Texture coordinates for bottom right corner of a mask. Default value: `vec2(1, 1)`.",
  mask2Flags: render.TextureMaskFlags = nil "Flags for the second mask. Default value: 6."
}]]
function ui.renderTexture(params)
  if type(params) ~= 'table' then error('Table “params” is required', 2) end
  ffi.C.lj_renderTexture_inner__ui(__util.str(params.filename), __util.ensure_vec2(params.p1), __util.ensure_vec2(params.p2), 
    __util.ensure_rgbm_nil(params.color), __util.ensure_rgbm_nil(params.colorOffset), __util.ensure_vec2_nil(params.uv1), __util.ensure_vec2_nil(params.uv2), 
    tonumber(params.blendMode) or 13,
    params.mask1 and tostring(params.mask1) or nil, __util.ensure_vec2_nil(params.mask1UV1), __util.ensure_vec2_nil(params.mask1UV2), tonumber(params.mask1Flags) or 6,
    params.mask2 and tostring(params.mask2) or nil, __util.ensure_vec2_nil(params.mask2UV1), __util.ensure_vec2_nil(params.mask2UV2), tonumber(params.mask2Flags) or 6)
end

---Draws a quad with a custom shader. Shader is compiled at first run, which might take a few milliseconds.
---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
---while drawing will be skipped until shader is ready.
---
---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
---it a very effective tool for any custom drawing you might need to make.      
---
---Example:
---```
---ui.renderShader({
---  async = true,
---  p1 = vec2(),
---  p2 = ui.windowSize(),
---  blendMode = render.BlendMode.BlendAdd,
---  textures = {
---    txInput1 = 'texture.png',  -- any key would work, but it’s easier to have a common prefix like “tx”
---    txInput2 = mediaPlayer,
---    txMissing = false
---  },
---  values = {
---    gValueColor = rgbm(1, 2, 0, 0.5),  -- any key would work, but it’s easier to have a common prefix like “g”
---    gValueNumber = math.random(),
---    gValueVec = vec2(1, 2),
---    gFlag = math.random() > 0.5
---  },
---  shader = [[
---    float4 main(PS_IN pin) { 
---      float4 in1 = txInput1.Sample(samAnisotropic, pin.Tex);
---      float4 in2 = txInput2.Sample(samAnisotropic, pin.Tex + gValueVec);
---      return gFlag ? in1 + in2 * gValueColor : in2;
---    }
---  ]]
---})
---```
---
---Tip: to simplify and speed things up, it might make sense to move table outside of a function to reuse it from frame
---to frame, simply accessing and updating textures, values and other parameters before call. However, make sure not to
---add new textures and values, otherwise it would require to recompile shader and might lead to VRAM leaks (if you would
---end up having thousands of no more used shaders). If you don’t have a working texture at the time of first creating
---that table, use `false` for missing texture value.
---
---Note: if shader would fail to compile, a C++ exception will be triggered, terminating script completely (to prevent AC 
---from crashing, C++ exceptions halt Lua script that triggered them until script gets a full reload).
---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
--[[@tableparam params {
  p1: vec2 = vec2(0, 0) "Position of upper left corner relative to whole screen or canvas.",
  p2: vec2 = vec2(1, 1) "Position of bottom right corner relative to whole screen or canvas.",
  uv1: vec2 = nil "Texture coordinates for upper left corner. Default value: `vec2(0, 0)`.",
  uv2: vec2 = nil "Texture coordinates for bottom right corner. Default value: `vec2(1, 1)`.",
  blendMode: render.BlendMode = render.BlendMode.BlendAccurate "Blend mode. Default value: `render.BlendMode.BlendAccurate`.",
  async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
  cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
  defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
  textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
  values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
  directValuesExchange: boolean = nil "If you’re reusing table between calls instead of recreating it each time and pass `true` as this parameter, `values` table will be swapped with an FFI structure allowing to skip data copying step and achieve the best performance. Note: with this mode, you’ll have to transpose matrices manually.",
  shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
}]]
function ui.renderShader(params)
  local dc = __util.setShaderParams2(params, _sp_uiu)
  if not dc then return false end
  ffi.C.lj_uicshader_enqueue__ui(dc, __util.ensure_vec2(params.p1), __util.ensure_vec2(params.p2), 
    __util.ensure_vec2_nil(params.uv1), __util.ensure_vec2_nil(params.uv2))
  return true
end

---Begins new group offset horizontally to the right, pushes item width to fill available space. Call `ui.endSubgroup()` when done.
---@param offsetX number? @Default value: 20.
function ui.beginSubgroup(offsetX)
  ui.offsetCursorX(tonumber(offsetX) or 20)
  ui.beginGroup()
  ui.pushItemWidth(ui.availableSpaceX())
end

---Ends group began with `ui.beginSubgroup()`.
function ui.endSubgroup()
  ui.popItemWidth()
  ui.endGroup()
end

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

---@param source string @URL, filename or binary data.
---@return ui.GIFPlayer
function ui.GIFPlayer(source) 
  return ffi.gc(ffi.C.lj_gifholder_new__ui(__util.blob(source)), ffi.C.lj_gifholder_gc__ui)
end

---GIF player can be used to display animated GIFs. Also supports regular and animated WEBP images.
---@class ui.GIFPlayer
---@field keepRunning boolean @By default GIFs stop playing if they are not actively used in rendering. If you need them to keep running in background, set this property to `true`.
---@explicit-constructor ui.GIFPlayer
ffi.metatype('gifholder', { 
  __tostring = function (s)
    return string.format('$ui.GIFPlayer://?id=%d', s._id)
  end,
  __index = {
    ---Get GIF resolution. If GIF is not yet loaded, returns zeroes.
    ---@return vec2 @Width and height in pixels.
    resolution = function (s)
      return s._resolution
    end,

    ---Rewinds GIF back to beginning.
    ---@return boolean
    rewind = ffi.C.lj_gifholder_rewind__ui,

    ---Checks if GIF is loaded and ready to be drawn.
    ---@return boolean
    ready = function (s)
      if not s._has_anything then s._required = true end
      return s._has_anything
    end,

    ---Returns `false` if GIF decoding has failed.
    ---@return boolean
    valid = function (s)
      return s._is_valid
    end
  }
})

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
  __tostring = function (s)
    return string.format('$ui.SharedTexture://?id=%d', s._id)
  end,
  __index = {
    ---Dispose texture and release its view. Call this method if remote texture is being destroyed.
    dispose = ffi.C.lj_sharedtex_dispose__ui,

    ---Get texture handle used for creating a texture. If texture has failed to load, returns 0. If texture is loaded by name and loaded properly, returns 1.
    ---@return integer
    handle = function (s)
      return s._handle
    end,

    ---Get texture resolution. If texture has failed to load, returns zeroes. 
    ---@return vec2 @Width and height in pixels.
    resolution = function (s)
      return s._resolution
    end,

    ---Returns `false` if access to a shared texture has failed.
    ---@return boolean
    valid = function (s)
      return s._has_anything
    end
  }
})

-- Thing for capturing input

ffi.cdef [[ 
typedef struct {
  lua_string_ref __queue;
  int pressedCount;
  int releasedCount;
  int pressed[256];
  int released[256];
  bool __down[256];
  uint64_t __last_frame;
  bool repeated[256];
} uicapturedinput;
]]

---Stops rest of Assetto Corsa from responding to keyboard events (key bindings, etc.), also sets `getUI().wantCaptureKeyboard` flag. 
---Note: if you writing a script reacting to general keyboard events, consider checking that flag to make sure IMGUI doesn’t have 
---keyboard captured currently.
---
---Resulting structure is a good way to access keyboard input data, both the button events and characters being entered.
---@param wantCaptureKeyboard boolean? @Default value: `true`.
---@param wantCaptureText boolean? @Default value: `false`.
---@return ui.CapturedKeyboard
function ui.captureKeyboard(wantCaptureKeyboard, wantCaptureText)
  return ffi.C.lj_captureKeyboard_inner__ui(wantCaptureKeyboard ~= false, wantCaptureText == true)
end

local iabr

---Similar to `ui.invisibleButton()`, but this one can be activated similar to text input and if it is active, will monitor keyboard state.
---@param id string? @Default value: `'nil'`.
---@param size vec2? @Default value: `vec2(0, 0)`.
---@return ui.CapturedKeyboard?
---@return boolean @Set to `true` if area was just activated.
function ui.interactiveArea(id, size)
  if not iabr then
    iabr = refbool()
  end
  local r = ffi.C.lj_interactiveArea_inner__ui(tostring(id), __util.ensure_vec2(size), iabr)
  return r ~= nil and r or nil, iabr.value
end

local acpp

---Create a new popup. Function `callback()` will be called each frame to render its content until popup is closed. Pass `title` in parameters to create
---a window instead (you can still call `ui.closePopup()` from the window to close it).
---@param callback fun()
---@param params {onClose: fun()?, position: vec2?, pivot: vec2?, size: vec2|{min: vec2?, max: vec2?, initial: vec2?}?, padding: vec2?, flags: ui.WindowFlags?, backgroundColor: rgbm?, title: string?}?
function ui.popup(callback, params)
  if not acpp then acpp = {} end

  params = params or {}
  local opened, children = params.title ~= nil, {}
  local listener
  local lastFrameDrawn = -1
  local id = (params.title and '\1w'..tostring(params.title)..'###' or '\1')..tostring(math.randomKey()) -- '\1' prefix makes IDs for popups absolute
  local rb = params.title and refbool(true)
  local sizeSet, positionSet = false, false

  local fn = function ()
    local frame = ui.frameCount()
    if frame == lastFrameDrawn then return end
    lastFrameDrawn = frame
    if not opened then
      opened = true
      ui.openPopup(id)
    end
    if params.position and not positionSet then
      ui.setNextWindowPosition(params.position, params.pivot)
    end
    if params.size then
      if type(params.size) == 'table' then
        ui.setNextWindowSizeConstraints(params.size.min, params.size.max)
        if params.size.initial and not sizeSet then
          ui.setNextWindowSize(params.size.initial)
        end
      elseif vec2.isvec2(params.size) then
        ui.setNextWindowSize(params.size)
      end
    end
    if params.backgroundColor then
      ui.pushStyleColor(ui.StyleColor.PopupBg, params.backgroundColor)
    end
    local began
    local flags = bit.bor(params.flags or 0, ui.WindowFlags.NoSavedSettings)
    if not params.title then
      ffi.C.lj_setNextWindowExtraTweaks_inner__ui(1) -- to fix selectables
      began = ui.beginPopup(id, flags, __util.ensure_vec2_nil(params.padding))
    else
      began = ui.beginPopup(id, flags, __util.ensure_vec2_nil(params.padding), rb)
      if not rb.value then
        if began then ffi.C.lj_end_inner__ui() end
        listener()
        if params and params.onClose then params.onClose() end
        return
      end
      if began then
        positionSet = true
      end
    end
    if params.backgroundColor then
      ui.popStyleColor()
    end
    if began then
      sizeSet = true
      table.insert(acpp, children)
      local s, e = pcall(callback)
      table.remove(acpp)
      for i = #children, 1, -1 do
        children[i]()
      end
      if not s then ac.error(e) end
      if not params.title then
        ui.endPopup()
      else
        ffi.C.lj_end_inner__ui()
      end
    elseif not params.title then
      listener()
      if params and params.onClose then params.onClose() end
    end
  end

  if acpp[1] and not params.title then
    -- For popups opening other popups within them
    opened = true
    ui.openPopup(id)
    local lacpp = acpp[#acpp]
    table.insert(lacpp, fn)
    listener = function ()
      table.removeItem(lacpp, fn)
    end
  else
    listener = ui.onUIFinale(fn)
  end
end

---@class ui.CapturedKeyboard
---@field pressedCount integer @Number of buttons in `.pressed` array.
---@field pressed integer[] @Zero-based array of pressed buttons with direct access (be careful).
---@field repeated integer[] @Zero-based array of flags if pressed buttons are repeated (the same size as `pressed`).
---@field releasedCount integer @Number of buttons in `.released` array.
---@field released integer[] @Zero-based array of released buttons with direct access (be careful).
ffi.metatype('uicapturedinput', {    
  __len = function (s)
    return s.__queue.p1
  end,
  __tostring = function (s)
    return s:queue()
  end,
  __index = {
    ---Characters being typed. Automatically takes into account keyboard layout, held shift and all that stuff.
    ---@return string @Empty string if there were no characters.
    queue = function (s)
      if s.__queue.p1 == 0 then return '' end
      return __util.strrefr(s.__queue)
    end,

    ---@return boolean
    down = function (s, index)
      return index > 0 and index < 256 and s.__down[index]
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyCtrl = function (s, button)
      return s.__down[17] and not s.__down[16] and not s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyShift = function (s, button)
      return not s.__down[17] and s.__down[16] and not s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyAlt = function (s, button)
      return not s.__down[17] and not s.__down[16] and s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyCtrlShift = function (s, button)
      return s.__down[17] and s.__down[16] and not s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyCtrlAlt = function (s, button)
      return s.__down[17] and not s.__down[16] and s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,

    ---@param button ui.KeyIndex?
    ---@return boolean
    hotkeyCtrlShiftAlt = function (s, button)
      return s.__down[17] and s.__down[16] and s.__down[18] and (not button or ui.keyboardButtonPressed(button))
    end,
  }
})

local _uilCache = {}

---Creates a new layer with user icons. Use `carN::special::driver` to draw an icon of a driver in a certain car (replace N with 0-based car index).
---@param priority integer @Layer with higher priority will be used.
---@param column number? @Column. If set, extra icons per user can be set. Columns are ordered from lowest to biggest. To get number of icon columns use `ac.getCar().extraIconsCount`. To draw an icon X, use `carN::special::driver::X`. Note: unlike main icons, those extra icons are not drawn in most parts of UI. New CSP UI only draws up to two extra icons per driver.
---@return fun(carIndex: integer, icon: ui.Icons) @Call this function to override actual icons using 0-based car index. Note: car scripts can override icon of their drivers only.
function ui.UserIconsLayer(priority, column)
  local cache
  if type(column) == 'number' then
    cache = _uilCache[tostring(column)]
    if not cache then
      cache = {}
      _uilCache[tostring(column)] = cache
    end
  else
    column = math.huge
    cache = _uilCache
  end
  local existing = cache[priority]
  if not existing then
    local set = {}
    ac.onRelease(function ()
      for k, v in pairs(set) do
        if v then
          ffi.C.lj_setUserIcon_inner__ui(k, priority, column, nil)
        end
      end
    end)
    existing = function (carIndex, icon)
      carIndex = tonumber(carIndex) or 0
      if not icon and not set[carIndex] then return end
      set[carIndex] = icon and true or false
      ffi.C.lj_setUserIcon_inner__ui(carIndex, priority, column, icon and tostring(icon) or nil)
    end
    cache[priority] = existing
  end
  return existing
end

local ir1, ir2 = vec2(), vec2()

---Note: unlike `ui.itemRectMin()` and `ui.itemRectMax()`, this one returns references instead of creating new vectors. Be careful if you 
---are to call this function and reuse results after calling it again.
---@return vec2
---@return vec2
function ui.itemRect()
  ffi.C.lj_itemRect_inner__ui(ir1, ir2)
  return ir1, ir2
end

---Adds a new settings item in settings list in apps.
--[[@tableparam params {
  icon: ui.Icons = ui.Icons.Settings "Settings icon",
  name: string "Name of the settings item (name of a script by default).",
  size: {default: vec2, min: vec2, max: vec2} = nil "Size settings. Default size: `vec2(320, 240)`, default min size: `vec2(40, 20)`.",
  id: string = nil "If specified, state of a window will be remembered across AC runs or Lua reloads.",
  padding: vec2 = nil "Custom padding for the window.",
  backgroundColor: rgbm = nil "Custom background color for the window.",
  category: 'settings'|'main'|'developer'|nil = nil "Optionally, this function can be used for simply creating new apps.",
  onClose: fun() = nil "Callback called when the tool is closed",
  onMenu: fun() = nil "Callback for extra items in context menu opening from taskbar.",
  onRemove: fun() = nil "Callback called once when the tool is removed. If set, there will be an item for removing the tool in taskbar context menu.",
  keepClosed: boolean = nil "Set to `true` to keep app closed even if it was opened before."
}]]
---@param callback fun() @Callback function to draw contents of the settings window.
---@return ac.Disposable|fun(command: 'open'|'close'|'toggle'|'opened'|'focus'|string): any
function ui.addSettings(params, callback)
  if type((params or error('Argument “params” is required', 2)).onRemove) == 'function' then
    params = table.assign({}, params, {
      onClose = params.onClose and __util.setCallback(params.onClose),
      onMenu = params.onMenu and __util.setCallback(params.onMenu),
      onRemove = params.onRemove and __util.expectReply(params.onRemove),
    }) 
  end
  local key = ffi.C.lj_addSettings_inner__ui(__util.json(params), __util.setCallback(callback), false)
  if key == 0 then return function () end end
  return function(c)
    if type(c) == 'string' then 
      ffi.C.lj_addSettings_inner__ui(c, key, true)
      return __util.result()
    else 
      __util.disposable_impl(key)
    end
  end
  -- return __util.disposable(ffi.C.lj_addSettings_inner__ui(__util.json(params), __util.setCallback(callback)))
end

---@param from integer @1-based index, similar to string.sub().
---@param to integer @1-based index, similar to string.sub().
---@param color rgbm|nil @Default value: `nil`.
---@param bold boolean|nil @Default value: `nil`.
function ui.setNextTextSpanStyle(from, to, color, bold)
  if from > 1e10 then return end
  if to > 1e10 then to = 1e8 end
  if bold ~= nil then
    ffi.C.lj_setNextTextSpanStyle_inner2__ui(from, to, __util.ensure_rgbm_nil(color), bold ~= false)
  else
    ffi.C.lj_setNextTextSpanStyle_inner1__ui(from, to, __util.ensure_rgbm_nil(color))
  end
end

---@param command 'getSelected'|'getText'|'setText'|'keepStateOnEscape'|'suggest'|'selectAll'|'delete'|'undo'|'redo'|'paste'|'copy'|'cut'|''
---@param argument string|number|boolean|nil @Default value: `nil`.
---@param lookActive boolean? @Default value: `true`.
---@return string?
function ui.inputTextCommand(command, argument, lookActive) 
	return __util.strrefp(ffi.C.lj_inputTextCommand_inner__ui(__util.str(command), __util.str_opt(argument), lookActive ~= false))
end

ui.setFontBoldEffect = function () end
