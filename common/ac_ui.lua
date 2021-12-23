__source 'lua/api_ui.cpp'
__namespace 'ui'

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

ui.Icons = __enum({ override = 'ui.icon24/iconID:*', underlying = 'string' }, {
  --[[? out($.readText(`${process.env['CSP_ROOT']}/source/imgui/icons.h`).split('\n')
    .map(x => /ICON_24_(\w+)/.test(x) && RegExp.$1).filter(x => x)
    .map(x => `${x.toLowerCase().replace(/^(?:gps|fm)$|(?<=^|_)[a-z]/g, _ => _.toUpperCase()).replace(/_/g, '')} = "${x}", -- ![Icon](https://acstuff.ru/images/icons_24/${x.toLowerCase()}.png)`).join('\n')) ?]]
})

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
  NoTitleBar                = 0x1,       -- Disable title-bar
  NoResize                  = 0x2,       -- Disable user resizing with the lower-right grip
  NoMove                    = 0x4,       -- Disable user moving the window
  NoScrollbar               = 0x8,       -- Disable scrollbars (window can still scroll with mouse or programmatically)
  NoScrollWithMouse         = 0x10,      -- Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
  NoCollapse                = 0x20,      -- Disable user collapsing window by double-clicking on it
  AlwaysAutoResize          = 0x40,      -- Resize every window to its content every frame
  NoBackground              = 0x80,      -- Disable drawing background and outside border.
  NoSavedSettings           = 0x100,     -- Never load/save settings in .ini file
  NoMouseInputs             = 0x200,     -- Disable catching mouse, hovering test with pass through.
  MenuBar                   = 0x400,     -- Has a menu-bar
  HorizontalScrollbar       = 0x800,     -- Allow horizontal scrollbar to appear (off by default)
  NoFocusOnAppearing        = 0x1000,    -- Disable taking focus when transitioning from hidden to visible state
  NoBringToFrontOnFocus     = 0x2000,    -- Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
  AlwaysVerticalScrollbar   = 0x4000,    -- Always show vertical scrollbar (even if ContentSize.y < Size.y)
  AlwaysHorizontalScrollbar = 0x8000,    -- Always show horizontal scrollbar (even if ContentSize.x < Size.x)
  AlwaysUseWindowPadding    = 0x10000,   -- Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
  NoNavInputs               = 0x40000,   -- No gamepad/keyboard navigation within the window
  NoNavFocus                = 0x80000,   -- No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
  UnsavedDocument           = 0x100000,  -- Append “*” to title without affecting the ID, as a convenience to avoid using the “###” operator
  NoNav                     = 0xc0000,   -- NoNavInputs | NoNavFocus,
  NoDecoration              = 0x2b,      -- NoTitleBar | NoResize | NoScrollbar | NoCollapse,
  NoInputs                  = 0xc0200,   -- NoMouseInputs | NoNavInputs | NoNavFocus,
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
  EnterReturnsTrue       = 0x20,      -- Return `true` when Enter is pressed (as opposed to every time the value was modified)
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
  NoCloseWithMiddleMouseButton      = 0x8,   -- Disable behavior of closing tabs (that are submitted with p_open !   = NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open    = false.
  NoTabListScrollingButtons         = 0x10,  -- Disable scrolling buttons (apply when fitting policy is FittingPolicyScroll)
  NoTooltip                         = 0x20,  -- Disable tooltips when hovering a tab
  FittingPolicyResizeDown           = 0x40,  -- Resize tabs when they don’t fit
  FittingPolicyScroll               = 0x80,  -- Add scroll buttons when tabs don’t fit
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
---@param label string
---@param str string
---@param flags ui.InputTextFlags
---@return string
---@return boolean
function ui.inputText(label, str, flags)
  local changed = ffi.C.lj_inputText_inner__ui(__util.str(label), __util.str(str), tonumber(flags) or 0)
  if changed == nil then return str, false end
  return ffi.string(changed), true
end

---Color picker control. Returns true if color has changed (as usual with Lua, colors are passed)
---by reference so update value would be put in place of old one automatically.
---@param label string
---@param color rgb|rgbm
---@param flags ui.ColorPickerFlags
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

---Show popup message.
---@param icon ui.Icons
---@param message string
---@param undoCallback fun() @If provided, there’ll be an undo button which, when clicked, will call this callback.
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
---@param content fun(): T @Window content callback.
---@return T
function ui.transparentWindow(id, pos, size, content)
  ui.beginTransparentWindow(id, pos, size, true)
  return using(content, ui.endTransparentWindow)
end

---Draw a window with semi-transparent background.
---@generic T
---@param id string @Window ID, has to be unique within your script.
---@param pos vec2 @Window position.
---@param size vec2 @Window size.
---@param content fun(): T @Window content callback.
---@return T
function ui.toolWindow(id, pos, size, content)
  ui.beginToolWindow(id, pos, size, true)
  return using(content, ui.endToolWindow)
end

---Draw a child window: perfect for clipping content, for scrolling lists, etc. Think of it more like
---a HTML div with overflow set to either scrolling or hidden, for example.
---@generic T
---@param id string @Window ID, has to be unique within given context (like, two sub-windows of the same window should have different IDs).
---@param size vec2 @Window size.
---@param border boolean @Window border.
---@param flags ui.WindowFlags @Window flags.
---@param content fun(): T @Window content callback.
---@return T
function ui.childWindow(id, size, border, flags, content)
  if content == nil then flags, content = content, flags end
  if content == nil then border, content = content, border end
  if content == nil then size, content = content, size end
  if ui.beginChild(id, size, border, flags) then
    return using(content, ui.endChild)
  end
end

---Draw a tree node element: a collapsible block with content inside it (which might include other tree
---nodes). Great for grouping things together. Note: if you need to have a tree node with changing label,
---use label like “your changing label###someUniqueID” for it to work properly. Everything after “###” will
---count as ID and not be shown. Same trick applies to other controls as well, such as tabs, buttons, etc.
---@generic T
---@param label string @Tree node label (which also acts like its ID).
---@param flags ui.TreeNodeFlags @Tree node flags.
---@param content fun(): T @Tree node content callback (called only if tree node is expanded).
---@return T
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
---@param flags ui.TabBarFlags @Tab bar flags.
---@param content fun(): T @Individual tabs callback.
---@return T
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
---@param flags ui.TabItemFlags @Tab flags.
---@param content fun(): T @Tab content callback (called only if tab is selected).
---@return T
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
---@param min number @Default value: 0.
---@param max number @Default value: 1.
---@param format string|'%.3f' @C-style format string. Default value: '%.3f'.
---@param power number @Power for non-linear slider. Default value: 1 (linear).
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

ffi.cdef [[ 
typedef struct {
  int _id;
  void* _mmf;
} mmfholder;
]]

---@param source string|nil @URL or a filename. Optional, can be set later with `player:setSource()`.
---@return ui.MediaPlayer
function ui.MediaPlayer(source) 
  local r = ffi.gc(ffi.C.lj_mmfholder_new__ui(), ffi.C.lj_mmfholder_gc__ui)
  if source ~= nil then r:setSource(source) end
  return r
end

---Media player which can load a video and be used as a texture in calls like `ui.drawImage()`, `ui.beginTextureShade()` or `display.image()`. Also, it can load an audio
---file and play it offscreen.
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
---@class ui.MediaPlayer
---@explicit-constructor ui.MediaPlayer
ffi.metatype('mmfholder', { 
  __tostring = function (s) return string.format('$ui.MediaPlayer://?id=%d', s._id) end,
  __index = {
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
    ---@param value number @New speed value from 0 to 1. Default value: 1.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setPlaybackRate = function (s, value) ffi.C.lj_mmfholder_setplaybackrate__ui(s, tonumber(value) or 1) return s end,
    
    ---Sets volume.
    ---@param value number @New volume value from 0 to 1. Default value: 1.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setVolume = function (s, value) ffi.C.lj_mmfholder_setvolume__ui(s, tonumber(value) or 1) return s end,
    
    ---Sets audio balance.
    ---@param value number @New balance value from -1 (left channel only) to 1 (right channel only). Default value: 0.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setBalance = function (s, value) ffi.C.lj_mmfholder_setbalance__ui(s, tonumber(value) or 0) return s end,

    ---Sets muted parameter.
    ---@param value number @Set to `true` to disable audio.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setMuted = function (s, value) ffi.C.lj_mmfholder_setmuted__ui(s, value == true) return s end,

    ---Sets looping parameter.
    ---@param value number @Set to `true` if video needs to start from beginning when it ends.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setLooping = function (s, value) ffi.C.lj_mmfholder_setlooping__ui(s, value == true) return s end,

    ---Sets auto playing parameter.
    ---@param value number @Set to `true` if video has to be started automatically.
    ---@return ui.MediaPlayer @Returns itself for chaining several methods together.
    setAutoPlay = function (s, value) ffi.C.lj_mmfholder_setautoplay__ui(s, value == true) return s end,

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
