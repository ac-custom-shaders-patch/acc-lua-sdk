ui.ImageFit = __enum({ cpp = 'aspect_ratio_mode', booleanCompatible = true }, {
  Stretch = 0,  -- Do not preserve aspect ratio (a bit faster too)
  Fill = 1,     -- Preserve aspect ratio, stretch image to fill out the area
  Fit = 2,      -- Preserve aspect ratio, shrink image leaving blank areas
})

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

ui.StyleVar = __enum({ cpp = 'ImGuiStyleVar' }, {
  Alpha = 0,  -- Expects a number.
  WindowRounding = 1,  -- Expects a number.
  WindowBorderSize = 2,  -- Expects a number.
  ChildRounding = 3,  -- Expects a number.
  ChildBorderSize = 4,  -- Expects a number.
  PopupRounding = 5,  -- Expects a number.
  PopupBorderSize = 6,  -- Expects a number.
  FrameRounding = 7,  -- Expects a number.
  FrameBorderSize = 8,  -- Expects a number.
  IndentSpacing = 9,  -- Expects a number.
  ScrollbarSize = 10,  -- Expects a number.
  ScrollbarRounding = 11,  -- Expects a number.
  GrabMinSize = 12,  -- Expects a number.
  GrabRounding = 13,  -- Expects a number.
  TabRounding = 14,  -- Expects a number.

  WindowPadding = 15, -- Expects a `vec2` value.
  WindowMinSize = 16, -- Expects a `vec2` value.
  WindowTitleAlign = 17, -- Expects a `vec2` value.
  FramePadding = 18, -- Expects a `vec2` value.
  ItemSpacing = 19, -- Expects a `vec2` value.
  ItemInnerSpacing = 20, -- Expects a `vec2` value.
  ButtonTextAlign = 21, -- Expects a `vec2` value.
  SelectableTextAlign = 22, -- Expects a `vec2` value.
  SelectablePadding = 23, -- Expects a `vec2` value.
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
  LoadingSpinner = 'fx:loading',
  --[[? out($.readText(`${process.env['CSP_ROOT']}/source/imgui/icons.h`).split('\n')
    .map(x => /ICON_24_(\w+)/.test(x) && RegExp.$1).filter(x => x)
    .map(x => `${x.toLowerCase().replace(/^(?:gps|fm|qr|vip)$|(?<=^|_)[a-z]/g, _ => _.toUpperCase()).replace(/_/g, '')} = "${x}", -- ![Icon](https://acstuff.ru/images/icons_24/${x.toLowerCase()}.png)`).join('\n')) ?]]
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
  Error                     = 0x8000,    -- For modern buttons
  Confirm                   = 0x10000,   -- For modern buttons
  Cancel                    = 0x20000,   -- For modern buttons
  VerticalLayout            = 0x40000,   -- For modern buttons
  TextAsIcon                = 0x80000,   -- For modern buttons
  Active                    = 0x100000,  -- Button is correctly active (checked)
  Activable                 = 0x200000,  -- If not set, _Active would make background brighter
})

ui.WindowFlags = __enum({ cpp = 'ImGuiWindowFlags' }, {
  None                      = 0,
  NoTitleBar                = 0x1,         -- Disable title-bar
  NoResize                  = 0x2,         -- Disable user resizing with the lower-right grip
  NoMove                    = 0x4,         -- Disable user moving the window
  NoScrollbar               = 0x8,         -- Disable scrollbars (window can still scroll with mouse or programmatically)
  NoScrollWithMouse         = 0x10,        -- Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
  NoCollapse                = 0x20,        -- Disable user collapsing window by double-clicking on it
  AlwaysAutoResize          = 0x40,        -- Resize every window to its content every frame
  NoBackground              = 0x80,        -- Disable drawing background and outside border
  NoSavedSettings           = 0x100,       -- Never load/save settings in .ini file
  NoMouseInputs             = 0x200,       -- Disable catching mouse, hovering test with pass through
  MenuBar                   = 0x400,       -- Has a menu-bar
  HorizontalScrollbar       = 0x800,       -- Allow horizontal scrollbar to appear (off by default)
  NoFocusOnAppearing        = 0x1000,      -- Disable taking focus when transitioning from hidden to visible state
  NoBringToFrontOnFocus     = 0x2000,      -- Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
  AlwaysVerticalScrollbar   = 0x4000,      -- Always show vertical scrollbar (even if ContentSize.y < Size.y)
  AlwaysHorizontalScrollbar = 0x8000,      -- Always show horizontal scrollbar (even if ContentSize.x < Size.x)
  AlwaysUseWindowPadding    = 0x10000,     -- Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
  NoNavInputs               = 0x40000,     -- No gamepad/keyboard navigation within the window
  NoNavFocus                = 0x80000,     -- No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
  UnsavedDocument           = 0x100000,    -- Append “*” to title without affecting the ID, as a convenience to avoid using the “###” operator
  NoNav                     = 0xc0000,     -- NoNavInputs | NoNavFocus
  NoDecoration              = 0x2b,        -- NoTitleBar | NoResize | NoScrollbar | NoCollapse
  NoInputs                  = 0xc0200,     -- NoMouseInputs | NoNavInputs | NoNavFocus
  ToolTip                   = 0x2000000,   -- @hidden
  Popup                     = 0x4000000,   -- @hidden
  Modal                     = 0x8000000,   -- @hidden
  Topmost                   = 0x20000000,  -- @hidden
  BitmapCache               = 0x40000000,  -- Cache window contents
  ThinScrollbar             = 0x80000000,  -- Thin scrollbar
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
  ClearButton            = 0x800000,  -- Add button erasing text
  RetainSelection        = 0x1000000  -- Do not lose selection when Enter is pressed, do not select all with focusing in code
})

ui.SelectableFlags = __enum({ cpp = 'ImGuiSelectableFlags' }, {
  None                  = 0,
  DontClosePopups       = 0x1,  -- Clicking this don’t close parent popup window
  SpanAllColumns        = 0x2,  -- Selectable frame can span all columns (text will still fit in current column)
  AllowDoubleClick      = 0x4,  -- Generate press events on double clicks too
  Disabled              = 0x8,  -- Cannot be selected, display grayed out text
  SpanClipRect          = 128,  -- Span entire left to right current clip rect boundary (use carefully)
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
  IntegratedTabs                    = 0x8000, -- Integrates tab bar into a window title (call it first when drawing a window)
  SaveSelected                      = 0x10000, -- Save selected tab based on tab ID (make sure tab ID is unique)
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
  SpanClipRect            = 0x8000,  -- Span entire left to right current clip rect boundary (use carefully)
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

ui.OnlineExtraFlags = __enum({ cpp = 'online_extra_flags' }, {
  None = 0,
  Admin = 1,  -- Feature will be available only to people signed up as admins with access to admin menu in that new chat app.
  Tool = 2    -- Instead of creating a modal popup blocking rest of UI, a tool would create a small window staying on screen continuously and be able to use rest of UI API there.
})
