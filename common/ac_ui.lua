__source 'lua/api_ui.cpp'
__source 'lua/api_ui_gif.cpp'
__namespace 'ui'

require './ac_render_shader'

---UI namespace for creating custom widgets or drawing dynamic textures using IMGUI.
ui = {}

ui.CornerFlags = __enum({ cpp = 'ImDrawCornerFlags' }, {
  None = 0,
  TopLeft = 1,
  TopRight = 2,
  BottomLeft = 4,
  BottomRight = 8,
  Top = 3,
  Bottom = 12,
  Left = 5,
  Right = 10,
  All = 15
})

ui.Direction = __enum({ cpp = 'ImGuiDir' }, {
  None = -1,
  Left = 0,
  Right = 1,
  Up = 2,
  Down = 3,
})

ui.HoveredFlags = __enum({ cpp = 'ImGuiHoveredFlags' }, {
  None                          = 0,    -- Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
  ChildWindows                  = 1,    -- `ac.windowHovered()` only: Return true if any children of the window is hovered
  RootWindow                    = 2,    -- `ac.windowHovered()` only: Test from root window (top most parent of the current hierarchy)
  AnyWindow                     = 4,    -- `ac.windowHovered()` only: Return true if any window is hovered
  AllowWhenBlockedByPopup       = 8,    -- Return true even if a popup window is normally blocking access to this item/window
  AllowWhenBlockedByActiveItem  = 32,   -- Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
  AllowWhenOverlapped           = 64,   -- Return true even if the position is obstructed or overlapped by another window
  AllowWhenDisabled             = 128,  -- Return true even if the item is disabled
  RectOnly                      = 104,  -- AllowWhenBlockedByPopup | AllowWhenBlockedByActiveItem | AllowWhenOverlapped,
  RootAndChildWindows           = 3     -- RootWindow | ChildWindows
})

ui.FocusedFlags = __enum({ cpp = 'ImGuiFocusedFlags' }, {
  None                          = 0,    -- Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
  ChildWindows                  = 1,    -- `ac.windowFocused()` only: Return true if any children of the window is hovered
  RootWindow                    = 2,    -- `ac.windowFocused()` only: Test from root window (top most parent of the current hierarchy)
  AnyWindow                     = 4,    -- `ac.windowFocused()` only: Return true if any window is hovered
  RootAndChildWindows           = 3     -- RootWindow | ChildWindows
})

ui.MouseCursor = __enum({ cpp = 'ImGuiMouseCursor' }, {
  None = -1,             -- No cursor
  Arrow = 0,             -- Default arrow
  TextInput = 1,         -- When hovering over `ui.inputText()`, etc.
  ResizeAll = 2,         -- Unused by default controls
  ResizeNS = 3,          -- When hovering over an horizontal border
  ResizeEW = 4,          -- When hovering over a vertical border or a column
  ResizeNESW = 5,        -- When hovering over the bottom-left corner of a window
  ResizeNWSE = 6,        -- When hovering over the bottom-right corner of a window
  Hand = 7,              -- Unused by default controls. Use for e.g. hyperlinks
})

ui.MouseButton = __enum({ override = 'ui.*/mouseButton:integer' }, {
  Left = 0,
  Right = 1,
  Middle = 2,
  Extra1 = 3,
  Extra2 = 4
})

ui.Font = __enum({ override = 'ui.*/fontType:integer' }, {
  Small = 1,
  Tiny = 2,
  Monospace = 3,
  Main = 4,
  Italic = 5,
  Title = 6,
  Huge = 7
})

ui.Alignment = __enum({ cpp = 'alignment' }, {
  Start = -1,
  Center = 0,
  End = 1
})

---Special codes for keys with certain UI roles.
ui.Key = __enum({ cpp = 'ImGuiKey', override = 'ui.*/keyCode:integer' }, { 
  Tab = 0,
  Left = 1,
  Right = 2,
  Up = 3,
  Down = 4,
  PageUp = 5,
  PageDown = 6,
  Home = 7,
  End = 8,
  Insert = 9,
  Delete = 10,
  Backspace = 11,
  Space = 12,
  Enter = 13,
  Escape = 14,
  KeyPadEnter = 15,
  A = 16,
  C = 17,
  D = 18,
  S = 19,
  V = 20,
  W = 21,
  X = 22,
  Y = 23,
  Z = 24,
})

---Key indices, pretty much mirrors all those “VK_…” key tables.
ui.KeyIndex = __enum({ cpp = 'vk_key', override = 'ui.*/keyIndex:integer' }, { 
  LeftButton = 0x01,
  RightButton = 0x02,
  Cancel = 0x03, -- @opt
  MiddleButton = 0x04, -- not contiguous with LeftButton and RightButton
  XButton1 = 0x05, -- not contiguous with LeftButton and RightButton
  XButton2 = 0x06, -- not contiguous with LeftButton and RightButton
  Back = 0x08, -- @opt
  Tab = 0x09,
  Clear = 0x0C, -- @opt
  Return = 0x0D,
  Shift = 0x10,
  Control = 0x11,
  Menu = 0x12, -- aka Alt button
  Pause = 0x13, -- @opt
  Capital = 0x14, -- @opt
  Kana = 0x15, -- @opt
  Hangeul = 0x15, -- old name - should be here for compatibility @opt
  Hangul = 0x15, -- @opt
  Junja = 0x17, -- @opt
  Final = 0x18, -- @opt
  Hanja = 0x19, -- @opt
  Kanji = 0x19, -- @opt
  Escape = 0x1B,
  Convert = 0x1C, -- @opt
  NonConvert = 0x1D, -- @opt
  Accept = 0x1E,
  ModeChange = 0x1F, -- @opt
  Space = 0x20,
  Prior = 0x21, -- @opt
  Next = 0x22, -- @opt
  End = 0x23,
  Home = 0x24,
  Left = 0x25, -- arrow ←
  Up = 0x26, -- arrow ↑
  Right = 0x27, -- arrow →
  Down = 0x28, -- arrow ↓
  Select = 0x29, -- @opt
  Print = 0x2A, -- @opt
  Execute = 0x2B, -- @opt
  Snapshot = 0x2C, -- @opt
  Insert = 0x2D,
  Delete = 0x2E,
  Help = 0x2F, -- @opt
  LeftWin = 0x5B,
  RightWin = 0x5C,
  Apps = 0x5D, -- @opt
  Sleep = 0x5F, -- @opt
  NumPad0 = 0x60,
  NumPad1 = 0x61,
  NumPad2 = 0x62,
  NumPad3 = 0x63,
  NumPad4 = 0x64,
  NumPad5 = 0x65,
  NumPad6 = 0x66,
  NumPad7 = 0x67,
  NumPad8 = 0x68,
  NumPad9 = 0x69,
  Multiply = 0x6A,
  Add = 0x6B,
  Separator = 0x6C,
  Subtract = 0x6D,
  Decimal = 0x6E,
  Divide = 0x6F,
  F1 = 0x70,
  F2 = 0x71,
  F3 = 0x72,
  F4 = 0x73,
  F5 = 0x74,
  F6 = 0x75,
  F7 = 0x76,
  F8 = 0x77,
  F9 = 0x78,
  F10 = 0x79,
  F11 = 0x7A,
  F12 = 0x7B,
  F13 = 0x7C, -- @opt
  F14 = 0x7D, -- @opt
  F15 = 0x7E, -- @opt
  F16 = 0x7F, -- @opt
  F17 = 0x80, -- @opt
  F18 = 0x81, -- @opt
  F19 = 0x82, -- @opt
  F20 = 0x83, -- @opt
  F21 = 0x84, -- @opt
  F22 = 0x85, -- @opt
  F23 = 0x86, -- @opt
  F24 = 0x87, -- @opt
  NavigationView = 0x88, -- reserved @opt
  NavigationMenu = 0x89, -- reserved @opt
  NavigationUp = 0x8A, -- reserved @opt
  NavigationDown = 0x8B, -- reserved @opt
  NavigationLeft = 0x8C, -- reserved @opt
  NavigationRight = 0x8D, -- reserved @opt
  NavigationAccept = 0x8E, -- reserved @opt
  NavigationCancel = 0x8F, -- reserved @opt
  NumLock = 0x90,
  Scroll = 0x91,
  OemNecEqual = 0x92, -- “=” key on numpad @opt
  OemFjJisho = 0x92, -- “Dictionary” key @opt
  OemFjMasshou = 0x93, -- “Unregister word” key @opt
  OemFjTouroku = 0x94, -- “Register word” key @opt
  OemFjLoya = 0x95, -- “Left OYAYUBI” key @opt
  OemFjRoya = 0x96, -- “Right OYAYUBI” key @opt
  LeftShift = 0xA0,
  RightShift = 0xA1,
  LeftControl = 0xA2,
  RightControl = 0xA3,
  LeftMenu = 0xA4, -- aka left Alt button
  RightMenu = 0xA5, -- aka right Alt button
  BrowserBack = 0xA6, -- @opt
  BrowserForward = 0xA7, -- @opt
  BrowserRefresh = 0xA8, -- @opt
  BrowserStop = 0xA9, -- @opt
  BrowserSearch = 0xAA, -- @opt
  BrowserFavorites = 0xAB, -- @opt
  BrowserHome = 0xAC, -- @opt
  VolumeMute = 0xAD, -- @opt
  VolumeDown = 0xAE, -- @opt
  VolumeUp = 0xAF, -- @opt
  MediaNextTrack = 0xB0, -- @opt
  MediaPrevTrack = 0xB1, -- @opt
  MediaStop = 0xB2, -- @opt
  MediaPlayPause = 0xB3, -- @opt
  LaunchMail = 0xB4, -- @opt
  LaunchMediaSelect = 0xB5, -- @opt
  LaunchApp1 = 0xB6, -- @opt
  LaunchApp2 = 0xB7, -- @opt
  Oem1 = 0xBA, -- “;:” for US
  OemPlus = 0xBB, -- “+” any country @opt
  OemComma = 0xBC, -- “,” any country @opt
  OemMinus = 0xBD, -- “-” any country @opt
  OemPeriod = 0xBE, -- “.” any country @opt
  Oem2 = 0xBF, -- “/?” for US @opt
  Oem3 = 0xC0, -- “`~” for US @opt
  GamepadA = 0xC3, -- reserved @opt
  GamepadB = 0xC4, -- reserved @opt
  GamepadX = 0xC5, -- reserved @opt
  GamepadY = 0xC6, -- reserved @opt
  GamepadRightShoulder = 0xC7, -- reserved @opt
  GamepadLeftShoulder = 0xC8, -- reserved @opt
  GamepadLeftTrigger = 0xC9, -- reserved @opt
  GamepadRightTrigger = 0xCA, -- reserved @opt
  GamepadDpadUp = 0xCB, -- reserved @opt
  GamepadDpadDown = 0xCC, -- reserved @opt
  GamepadDpadLeft = 0xCD, -- reserved @opt
  GamepadDpadRight = 0xCE, -- reserved @opt
  GamepadMenu = 0xCF, -- reserved @opt
  GamepadView = 0xD0, -- reserved @opt
  GamepadLeftThumbstickButton = 0xD1, -- reserved @opt
  GamepadRightThumbstickButton = 0xD2, -- reserved @opt
  GamepadLeftThumbstickUp = 0xD3, -- reserved @opt
  GamepadLeftThumbstickDown = 0xD4, -- reserved @opt
  GamepadLeftThumbstickRight = 0xD5, -- reserved @opt
  GamepadLeftThumbstickLeft = 0xD6, -- reserved @opt
  GamepadRightThumbstickUp = 0xD7, -- reserved @opt
  GamepadRightThumbstickDown = 0xD8, -- reserved @opt
  GamepadRightThumbstickRight = 0xD9, -- reserved @opt
  GamepadRightThumbstickLeft = 0xDA, -- reserved @opt
  SquareOpenBracket = 0xDB,
  SquareCloseBracket = 0xDD,
  --[[? for (let i = 0; i < 10; ++i) out(`D${i} = 0x${(''+i).charCodeAt(0).toString(16)}, -- Digit ${i}\n`) ?]]
  --[[? for (let i = 'A'.charCodeAt(0); i <= 'Z'.charCodeAt(0); ++i) out(`${String.fromCharCode(i)} = 0x${i.toString(16)}, -- Letter ${String.fromCharCode(i)}\n`) ?]]
})

ui.StyleVar = __enum({ cpp = 'ImGuiStyleVar' }, {
  Alpha = 0,
  WindowPadding = 1,
  WindowRounding = 2,
  WindowBorderSize = 3,
  WindowMinSize = 4,
  WindowTitleAlign = 5,
  ChildRounding = 6,
  ChildBorderSize = 7,
  PopupRounding = 8,
  PopupBorderSize = 9,
  FramePadding = 10,
  FrameRounding = 11,
  FrameBorderSize = 12,
  ItemSpacing = 13,
  ItemInnerSpacing = 14,
  IndentSpacing = 15,
  ScrollbarSize = 16,
  ScrollbarRounding = 17,
  GrabMinSize = 18,
  GrabRounding = 19,
  TabRounding = 20,
  ButtonTextAlign = 21,
  SelectableTextAlign = 22,
  SelectablePadding = 23,
})

ui.StyleColor = __enum({ cpp = 'ImGuiCol' }, {
  Text = 0,
  TextDisabled = 1,
  WindowBg = 2,
  ChildBg = 3,
  PopupBg = 4,
  Border = 5,
  BorderShadow = 6,
  FrameBg = 7,
  FrameBgHovered = 8,
  FrameBgActive = 9,
  TitleBg = 10,
  TitleBgActive = 11,
  TitleBgCollapsed = 12,
  MenuBarBg = 13,
  ScrollbarBg = 14,
  ScrollbarGrab = 15,
  ScrollbarGrabHovered = 16,
  ScrollbarGrabActive = 17,
  CheckMark = 18,
  SliderGrab = 19,
  SliderGrabActive = 20,
  Button = 21,
  ButtonHovered = 22,
  ButtonActive = 23,
  Header = 24,
  HeaderHovered = 25,
  HeaderActive = 26,
  Separator = 27,
  SeparatorHovered = 28,
  SeparatorActive = 29,
  ResizeGrip = 30,
  ResizeGripHovered = 31,
  ResizeGripActive = 32,
  Tab = 33,
  TabHovered = 34,
  TabActive = 35,
  TabUnfocused = 36,
  TabUnfocusedActive = 37,
  PlotLines = 38,
  PlotLinesHovered = 39,
  PlotHistogram = 40,
  PlotHistogramHovered = 41,
  TextSelectedBg = 42,
  DragDropTarget = 43,
  NavHighlight = 44,
  NavWindowingHighlight = 45,
  NavWindowingDimBg = 46,
  ModalWindowDimBg = 47,
  TextHovered = 48,
  TextActive = 49
})

ui.Icons = __enum({ override = 'ui.*/*conID:string', underlying = 'string' }, {
  --[[? out($.readText(`${process.env['CSP_ROOT']}/source/imgui/icons.h`).split('\n')
    .map(x => /ICON_24_(\w+)/.test(x) && RegExp.$1).filter(x => x)
    .map(x => `${x.toLowerCase().replace(/^(?:gps|fm)$|(?<=^|_)[a-z]/g, _ => _.toUpperCase()).replace(/_/g, '')} = "${x}", -- ![Icon](https://acstuff.ru/images/icons_24/${x.toLowerCase()}.png)`).join('\n')) ?]]
})

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

ui.ButtonFlags = __enum({ cpp = 'ImGuiButtonFlags' }, {
  None                      = 0,
  Repeat                    = 0x1,       -- Hold to repeat
  PressedOnClickRelease     = 0x2,       -- Return true on click + release on same item
  PressedOnClick            = 0x4,       -- Return true on click (default requires click+release)
  PressedOnRelease          = 0x8,       -- Return true on release (default requires click+release)
  PressedOnDoubleClick      = 0x10,      -- Return true on double-click (default requires click+release)
  FlattenChildren           = 0x20,      -- Allow interactions even if a child window is overlapping
  AllowItemOverlap          = 0x40,      -- Require previous frame HoveredId to either match id or be null before being usable, use along with SetItemAllowOverlap()
  DontClosePopups           = 0x80,      -- Disable automatically closing parent popup on press
  Disabled                  = 0x100,     -- Disable interactions
  NoKeyModifiers            = 0x400,     -- Disable interaction if a key modifier is held
  PressedOnDragDropHold     = 0x1000,    -- Press when held into while we are drag and dropping another item (used by e.g. tree nodes, collapsing headers)
  NoNavFocus                = 0x2000,    -- Don’t override navigation focus when activated
  NoHoveredOnNav            = 0x4000,    -- Don’t report as hovered when navigated on
  Active                    = 0x100000,  -- Button is correctly active (checked)
  Activable                 = 0x200000,  -- If not set, _Active would make background brighter
})

ui.WindowFlags = __enum({ cpp = 'ImGuiWindowFlags' }, {
  None                      = 0,
  NoTitleBar                = 0x1,        -- Disable title-bar
  NoResize                  = 0x2,        -- Disable user resizing with the lower-right grip
  NoMove                    = 0x4,        -- Disable user moving the window
  NoScrollbar               = 0x8,        -- Disable scrollbars (window can still scroll with mouse or programmatically)
  NoScrollWithMouse         = 0x10,       -- Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
  NoCollapse                = 0x20,       -- Disable user collapsing window by double-clicking on it
  AlwaysAutoResize          = 0x40,       -- Resize every window to its content every frame
  NoBackground              = 0x80,       -- Disable drawing background and outside border.
  NoSavedSettings           = 0x100,      -- Never load/save settings in .ini file
  NoMouseInputs             = 0x200,      -- Disable catching mouse, hovering test with pass through.
  MenuBar                   = 0x400,      -- Has a menu-bar
  HorizontalScrollbar       = 0x800,      -- Allow horizontal scrollbar to appear (off by default)
  NoFocusOnAppearing        = 0x1000,     -- Disable taking focus when transitioning from hidden to visible state
  NoBringToFrontOnFocus     = 0x2000,     -- Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
  AlwaysVerticalScrollbar   = 0x4000,     -- Always show vertical scrollbar (even if ContentSize.y < Size.y)
  AlwaysHorizontalScrollbar = 0x8000,     -- Always show horizontal scrollbar (even if ContentSize.x < Size.x)
  AlwaysUseWindowPadding    = 0x10000,    -- Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
  NoNavInputs               = 0x40000,    -- No gamepad/keyboard navigation within the window
  NoNavFocus                = 0x80000,    -- No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
  UnsavedDocument           = 0x100000,   -- Append “*” to title without affecting the ID, as a convenience to avoid using the “###” operator
  NoNav                     = 0xc0000,    -- NoNavInputs | NoNavFocus,
  NoDecoration              = 0x2b,       -- NoTitleBar | NoResize | NoScrollbar | NoCollapse,
  NoInputs                  = 0xc0200,    -- NoMouseInputs | NoNavInputs | NoNavFocus,
  ToolTip                   = 0x2000000,  -- @hidden
  Popup                     = 0x4000000,  -- @hidden
  Modal                     = 0x8000000,  -- @hidden
  Topmost                   = 0x20000000, -- @hidden
})

ui.ComboFlags = __enum({ cpp = 'ImGuiComboFlags' }, {
  None                       = 0,
  PopupAlignLeft             = 0x1,    -- Align the popup toward the left by default
  HeightSmall                = 0x2,    -- Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
  HeightRegular              = 0x4,    -- Max ~8 items visible (default)
  HeightLarge                = 0x8,    -- Max ~20 items visible
  HeightLargest              = 0x10,   -- As many fitting items as possible
  NoArrowButton              = 0x20,   -- Display on the preview box without the square arrow button
  NoPreview                  = 0x40,   -- Display only a square arrow button
  GoUp                       = 0x80,   -- Dropdown goes up
  HeightChubby               = 0x100,  -- Height between regular and large
})

ui.InputTextFlags = __enum({ cpp = 'ImGuiInputTextFlags' }, {
  None                   = 0,
  CharsDecimal           = 0x1,       -- Allow “0123456789.+-*/”
  CharsHexadecimal       = 0x2,       -- Allow “0123456789ABCDEFabcdef”
  CharsUppercase         = 0x4,       -- Turn a…z into A…Z
  CharsNoBlank           = 0x8,       -- Filter out spaces, tabs
  AutoSelectAll          = 0x10,      -- Select entire text when first taking mouse focus
  EnterReturnsTrue       = 0x20,      -- @hidden
  AllowTabInput          = 0x400,     -- Pressing TAB input a '\t' character into the text field
  CtrlEnterForNewLine    = 0x800,     -- In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter)
  NoHorizontalScroll     = 0x1000,    -- Disable following the cursor horizontally
  AlwaysInsertMode       = 0x2000,    -- Insert mode
  ReadOnly               = 0x4000,    -- Read-only mode
  Password               = 0x8000,    -- Password mode, display all characters as “*”
  NoUndoRedo             = 0x10000,   -- Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
  CharsScientific        = 0x20000,   -- Allow “0123456789.+-*/eE” (Scientific notation input)
  Placeholder            = 0x400000,  -- Show label as a placeholder
  ClearButton            = 0x800000   -- Add button erasing text
})

ui.SelectableFlags = __enum({ cpp = 'ImGuiSelectableFlags' }, {
  None                  = 0,
  DontClosePopups       = 0x1,  -- Clicking this don’t close parent popup window
  SpanAllColumns        = 0x2,  -- Selectable frame can span all columns (text will still fit in current column)
  AllowDoubleClick      = 0x4,  -- Generate press events on double clicks too
  Disabled              = 0x8,  -- Cannot be selected, display grayed out text
})

ui.TabBarFlags = __enum({ cpp = 'ImGuiTabBarFlags' }, {
  None                              = 0,
  Reorderable                       = 0x1,   -- Allow manually dragging tabs to re-order them + New tabs are appended at the end of list
  AutoSelectNewTabs                 = 0x2,   -- Automatically select new tabs when they appear
  TabListPopupButton                = 0x4,   -- Disable buttons to open the tab list popup
  NoCloseWithMiddleMouseButton      = 0x8,   -- Disable behavior of closing tabs with middle mouse button
  NoTabListScrollingButtons         = 0x10,  -- Disable scrolling buttons (apply when fitting policy is FittingPolicyScroll)
  NoTooltip                         = 0x20,  -- Disable tooltips when hovering a tab
  FittingPolicyResizeDown           = 0x40,  -- Resize tabs when they don’t fit
  FittingPolicyScroll               = 0x80,  -- Add scroll buttons when tabs don’t fit
  IntegratedTabs                    = 0x8000 -- Integrates tab bar into a window title (call it first when drawing a window)
})

ui.TabItemFlags = __enum({ cpp = 'ImGuiTabItemFlags' }, {
  None                             = 0,
  UnsavedDocument                  = 0x1,   -- Append '*' to title without affecting the ID, as a convenience to avoid using the ### operator. Also: tab is selected on closure and closure is deferred by one frame to allow code to undo it without flicker.
  SetSelected                      = 0x2,   -- Trigger flag to programmatically make the tab selected when calling BeginTabItem()
  NoCloseWithMiddleMouseButton     = 0x4,   -- Disable behavior of closing tabs (that are submitted with p_open !   = NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open    = false.
})

ui.TreeNodeFlags = __enum({ cpp = 'ImGuiTreeNodeFlags' }, {
  None                    = 0,
  Selected                = 0x1,    -- Draw as selected
  Framed                  = 0x2,    -- Full colored frame (e.g. for CollapsingHeader)
  AllowItemOverlap        = 0x4,    -- Hit testing to allow subsequent widgets to overlap this one
  NoTreePushOnOpen        = 0x8,    -- Don’t do a TreePush() when open (e.g. for CollapsingHeader)    = no extra indent nor pushing on ID stack
  NoAutoOpenOnLog         = 0x10,   -- Don’t automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
  DefaultOpen             = 0x20,   -- Default node to be open
  OpenOnDoubleClick       = 0x40,   -- Need double-click to open node
  OpenOnArrow             = 0x80,   -- Only open when clicking on the arrow part. If OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.
  Leaf                    = 0x100,  -- No collapsing, no arrow (use as a convenience for leaf nodes).
  Bullet                  = 0x200,  -- Display a bullet instead of arrow
  FramePadding            = 0x400,  -- Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().
  CollapsingHeader        = 0x1a,   -- Framed | NoTreePushOnOpen | NoAutoOpenOnLog,
  NoArrow                 = 0x4000,
  Animated                = 0xf0000000,
})

ui.ColorPickerFlags = __enum({ cpp = 'ImGuiColorEditFlags' }, {
  None             = 0,
  NoAlpha          = 0x2,        -- Ignore Alpha component (will only read 3 components from the input pointer).
  NoPicker         = 0x4,        -- Disable picker when clicking on colored square.
  NoOptions        = 0x8,        -- Disable toggling options menu when right-clicking on inputs/small preview.
  NoSmallPreview   = 0x10,       -- Disable colored square preview next to the inputs. (e.g. to show only the inputs)
  NoInputs         = 0x20,       -- Disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
  NoTooltip        = 0x40,       -- Disable tooltip when hovering the preview.
  NoLabel          = 0x80,       -- Disable display of inline text label (the label is still forwarded to the tooltip and picker).
  NoSidePreview    = 0x100,      -- Disable bigger color preview on right side of the picker, use small colored square preview instead.
  NoDragDrop       = 0x200,      -- Disable drag and drop target. ColorButton: disable drag and drop source.
  AlphaBar         = 0x10000,    -- Show vertical alpha bar/gradient in picker.
  AlphaPreview     = 0x20000,    -- Display preview as a transparent color over a checkerboard, instead of opaque.
  AlphaPreviewHalf = 0x40000,    -- Display half opaque / half checkerboard, instead of opaque.
  DisplayRGB       = 0x100000,   -- Override _display_ type among RGB/HSV/Hex. select any combination using one or more of RGB/HSV/Hex.
  DisplayHSV       = 0x200000,
  DisplayHex       = 0x400000,
  UInt8            = 0x800000,   -- Display values formatted as 0..255.
  Uint8            = 0x800000,   -- @hidden
  Float            = 0x1000000,  -- Display values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
  PickerHueBar     = 0x2000000,  -- Bar for Hue, rectangle for Sat/Value.
  PickerHueWheel   = 0x4000000,  -- Wheel for Hue, triangle for Sat/Value
})

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

---Text input control. Returns updated string (which would be the input string unless it changed, so no)
---copying there. Second return value would change to `true` when text has changed. Example:
---```
---myText = ui.inputText('Enter something:', myText)
---```
---
---Third argument is `true` if Enter was pressed while editing text.
---@param label string
---@param str string
---@param flags ui.InputTextFlags?
---@return string
---@return boolean
---@return boolean
function ui.inputText(label, str, flags)
  local changed = ffi.C.lj_inputText_inner__ui(__util.str(label), __util.str(str), tonumber(flags) or 0)
  if changed == nil then return str, false, ui.itemActive() and ui.keyPressed(ui.Key.Enter) end
  return ffi.string(changed), true, ui.itemActive() and ui.keyPressed(ui.Key.Enter)
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
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(id: string, pos: vec2, size: vec2, content: fun())
function ui.transparentWindow(id, pos, size, noPadding, content)
  if type(noPadding) == 'function' then content, noPadding = noPadding, nil end
  ui.beginTransparentWindow(id, pos, size, noPadding == true)
  return using(content, ui.endTransparentWindow)
end

---Draw a window with semi-transparent background.
---@generic T
---@param id string @Window ID, has to be unique within your script.
---@param pos vec2 @Window position.
---@param size vec2 @Window size.
---@param noPadding boolean? @Disables window padding. Default value: `false`.
---@param content fun(): T @Window content callback.
---@return T
---@overload fun(id: string, pos: vec2, size: vec2, content: fun())
function ui.toolWindow(id, pos, size, noPadding, content)
  if type(noPadding) == 'function' then content, noPadding = noPadding, nil end
  ui.beginToolWindow(id, pos, size, noPadding == true)
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
  if ui.beginChild(id, size, border, flags) then
    return using(content, ui.endChild)
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
---@param content fun(): T @Combo box items callback.
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
---@param value refnumber @Current slider value.
---@param min number? @Default value: 0.
---@param max number? @Default value: 1.
---@param format string|'%.3f'|nil @C-style format string. Default value: '%.3f'.
---@param power number? @Power for non-linear slider. Default value: 1 (linear).
---@return boolean @True if slider has moved.
---@overload fun(label: string, value: number, min: number, max: number, format: string, power: number): number, boolean
function ui.slider(label, value, min, max, format, power)
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

function ui.DWriteFont:allowRealSizes()
  self._allowRealSizes = true
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
  int _id;
  void* _mmf;
} mmfholder;
]]

--[[? if (ctx.ldoc) out(]]

---Checks if system supports these media players (Microsoft Media Foundation framework was added in Windows 8). If it’s not supported,
---you can still use API, but it would fail to load any video or audio.
---@return boolean
function ui.MediaPlayer.supported() end

---@param source string|nil @URL or a filename. Optional, can be set later with `player:setSource()`.
---@return ui.MediaPlayer
function ui.MediaPlayer(source) end

--[[) ?]]

ui.MediaPlayer = setmetatable({
  supported = ffi.C.lj_mmfholder_supported__ui,
  supportedAsync = function(callback) return ffi.C.lj_mmfholder_supportedasync__ui(__util.expectReply(callback)) end
}, { 
  __call = function (obj, source) 
    local r = ffi.gc(ffi.C.lj_mmfholder_new__ui(), ffi.C.lj_mmfholder_gc__ui)
    if source ~= nil then r:setSource(source) end
    return r
  end 
})

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

    --Checks if streaming video is currently loading more data.
    --@ return boolean
    -- waitingForData = ffi.C.lj_mmfholder_getwaitingfordata__ui,

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
    debugText = function (s) return __util.strref(ffi.C.lj_mmfholder_debugtext__ui(s)) end,
  }
})

ffi.cdef [[ 
typedef struct { int _id; } uirt;
typedef struct { int _something; } uirtcpu;
]]

---@param resolution vec2|integer @Resolution in pixels. Usually textures with sizes of power of two work the best.
---@param mips integer? @Number of MIPs for a texture. MIPs are downsized versions of main texture used to avoid aliasing. Default value: 1 (no MIPs).
---@param antialiasingMode render.AntialiasingMode? @Antialiasing mode. Default value: `render.AntialiasingMode.None` (disabled).
---@param textureFormat render.TextureFormat? @Texture format. Default value: `render.TextureFormat.R8G8B8A8.UNorm`.
---@return ui.ExtraCanvas
---@overload fun(resolution: vec2|integer, mips: integer, textureFormat: render.TextureFormat)
function ui.ExtraCanvas(resolution, mips, antialiasingMode, textureFormat)
  if type(resolution) == 'number' then resolution = vec2(resolution, resolution) end
  if not vec2.isvec2(resolution) then error('Resolution is required', 2) end
  resolution.x = math.clamp(math.ceil(resolution.x), 1, 8192)
  resolution.y = math.clamp(math.ceil(resolution.y), 1, 8192)

  if antialiasingMode and antialiasingMode > 0 and antialiasingMode < 100 then
    antialiasingMode, textureFormat = textureFormat, antialiasingMode
  end

  return ffi.gc(ffi.C.lj_uirt_new__ui(resolution.x, resolution.y, tonumber(mips) or 1, tonumber(antialiasingMode) or 0, tonumber(textureFormat) or 28), ffi.C.lj_uirt_gc__ui)
end

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
      textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
      values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
      shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
    }]]
    updateWithShader = function (s, params)
      local dc = __util.setShaderParams(params, 'direct.fx', render.BlendMode.Opaque)
      if not dc then return false end
      ffi.C.lj_uicshader_runoncanvas__ui(s, dc, __util.ensure_vec2_nil(params.p1), __util.ensure_vec2_nil(params.p2), 
        __util.ensure_vec2_nil(params.uv1), __util.ensure_vec2_nil(params.uv2))
      return true
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
      textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
      values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
      shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
    }]]
    updateSceneWithShader = function (s, params)
      local dc = __util.setShaderParams(params, 'fullscreen.fx', render.BlendMode.Opaque)
      if not dc then return false end
      ffi.C.lj_uicshader_runoncanvas_fullscreen__ui(s, dc)
      return true
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
      return __util.strref(ffi.C.lj_uirt_tobytes__ui(s))
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

    ---Copies contents from another canvas or from CPU canvas data. Faster than copying by drawing, but works only
    ---if size and number of MIP maps match. If not, fails quietly.
    ---@param other ui.ExtraCanvas|ui.ExtraCanvasData @Canvas to copy content from.
    ---@return ui.ExtraCanvas @Returns itself for chaining several methods together.
    copyFrom = function(s, other)
      if ffi.istype('uirt*', other) then ffi.C.lj_uirt_copyfrom__ui(s, other)
      elseif ffi.istype('uirtcpu*', other) then ffi.C.lj_uirt_fromcpu__ui(s, other)
      else error('Can copy from ui.ExtraCanvas or ui.ExtraCanvasData only', 2) end
      return s;
    end,

    ---Downloads data from GPU to CPU asyncronously (usually takes about 0.15 ms to get the data). Resulting data can be
    ---used to access colors of individual pixels or upload it back to CPU restoring original state.
    ---@param callback fun(err: string, data: ui.ExtraCanvasData)
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

    ---Returns color of a pixel. If coordinates are outside, or data has been disposed, returns zeroes.
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
---@overload fun(key: ui.KeyIndex, ...): function
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
    tonumber(params.blendMode) or 15,
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
  textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
  values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
  shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/ui.fx”."
}]]
function ui.renderShader(params)
  local dc = __util.setShaderParams(params, 'ui.fx', render.BlendMode.Opaque)
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
  vec2 _resolution;
  void* _data;
} gifholder;
]]

---@param source string @URL, filename or binary data.
---@return ui.GIFPlayer
function ui.GIFPlayer(source) 
  return ffi.gc(ffi.C.lj_gifholder_new__ui(__util.blob(source)), ffi.C.lj_gifholder_gc__ui)
end

---GIF player can be used to display animated GIFs.
---@class ui.GIFPlayer
---@field keepRunning boolean @By default GIFs stop playing if they are not actively used in rendering. If you need them to keep running in background, set this property to `true`.
---@explicit-constructor ui.GIFPlayer
ffi.metatype('gifholder', { 
  __tostring = function (s)
    s._required = true
    return string.format('$ui.GIFPlayer://?id=%d', s._id)
  end,
  __index = {
    ---Get GIF resolution. If GIF is not yet loaded, returns zeroes.
    ---@return vec2 @Width and height in pixels.
    resolution = function (s)
      return vec2(s._resolution)
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