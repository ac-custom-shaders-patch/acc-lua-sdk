ac.FogAlgorithm = __enum({ cpp = 'fog_algorithm' }, { 
  Original = 0,
  New = 1
})

ac.SurfaceType = __enum({ cpp = 'outside_surface_type', underlying = 'uint8_t' }, { 
  Grass = 0,
  Dirt = 1,
  Default = 255
})

ac.ShadowsState = __enum({ cpp = 'shadows_state' }, { 
  Off = 0,
  On = 1,
  EverythingShadowed = 2
})

ac.TextureState = __enum({ cpp = 'async_texture_state' }, { 
  Empty = 0,
  Loading = 1,
  Failed = 2,
  Ready = 3
})

ac.CameraMode = __enum({ cpp = 'CameraMode' }, { 
  Cockpit = 0,     -- first person view
  Car = 1,         -- F6 camera
  Drivable = 2,    -- chase/bonnet/bumper/dash cameras
  Track = 3,       -- replay camera
  Helicopter = 4,  -- moving replay camera
  OnBoardFree = 5, -- F5 camera
  Free = 6,        -- F7 camera
  Deprecated = 7,
  ImageGeneratorCamera = 8,
  Start = 9,       -- starting camera
})

ac.DrivableCamera = __enum({ cpp = 'DrivableCamera' }, { 
  Chase = 0,
  Chase2 = 1,
  Bonnet = 2,
  Bumper = 3,
  Dash = 4,
})

---Wheel index (from 0 to 3) or a special value for wheel mask.
ac.Wheel = __enum({ cpp = 'ac_wheel' }, { 
  FrontLeft = 0,
  FrontRight = 1,
  RearLeft = 2,
  RearRight = 3,
  Front = 12,
  Rear = 48,
  Left = 20,
  Right = 40,
  All = 60
})

ac.MirrorPieceRole = __enum({ cpp = 'ac_mirrorpiece_role' }, { 
  None = 0,
  Top = 1,
  Left = 2,
  Right = 4
})

ac.MirrorPieceFlip = __enum({ underlying = 'int' }, { 
  None = 0,
  Horizontal = 1,
  Vertical = 2,
  Both = 3
})

ac.MirrorMonitorType = __enum({ underlying = 'int' }, { 
  TN = 0,   -- oldschool displays with a lot of color distortion
  VA = 2,   -- medium tier, less color distortion
  IPS = 1,  -- almost no color distortion
})

ac.WeatherType = __enum({ cpp = 'weather_type', underlying = 'char' }, { 
  LightThunderstorm = 0,
  Thunderstorm = 1,
  HeavyThunderstorm = 2,
  LightDrizzle = 3,
  Drizzle = 4,
  HeavyDrizzle = 5,
  LightRain = 6,
  Rain = 7,
  HeavyRain = 8,
  LightSnow = 9,
  Snow = 10,
  HeavySnow = 11,
  LightSleet = 12,
  Sleet = 13,
  HeavySleet = 14,
  Clear = 15,
  FewClouds = 16,
  ScatteredClouds = 17,
  BrokenClouds = 18,
  OvercastClouds = 19,
  Fog = 20,
  Mist = 21,
  Smoke = 22,
  Haze = 23,
  Sand = 24,
  Dust = 25,
  Squalls = 26,
  Tornado = 27,
  Hurricane = 28,
  Cold = 29,
  Hot = 30,
  Windy = 31,
  Hail = 32 
})

ac.TonemapFunction = __enum({ cpp = 'tonemap_function' }, {
  Linear = 0,         -- simple linear mapping.
  LinearClamped = 1,  -- linear mapping (LDR clamp)
  Sensitometric = 2,  -- simple simulation of response of film, CCD, etc., recommended
  Reinhard = 3,       -- Reinhard
  ReinhardLum = 4,    -- saturation retention type Reinhard tone map function
  Log = 5,            -- tone map function for the logarithmic space
  LogLum = 6,         -- saturation retention type logarithmic space tone map function
  ACES = 7,           -- ACES
  Uchimura = 8,       -- GT-like by Uchimura
  RomBinDaHouse = 9,  -- tonemapping by RomBinDaHouse
  Lottes = 10,        -- tonemapping by Lottes
  Uncharted = 11,     -- tonemapping used in Uncharted
  Unreal = 12,        -- tonemapping commonly used in UE
  Filmic = 13,        -- filmic tonemapping
  ReinhardWp = 14,    -- White-preserving Reinhard
})

ac.FolderID = __enum({ cpp = 'known_dir' }, {   
  AppData = 0,          -- …/AppData
  Documents = 1,        -- …/Documents
  Root = 4,             -- …/SteamApps/common/assettocorsa
  Cfg = 5,              -- …/Documents/Assetto Corsa/cfg
  Setups = 6,           -- @hidden
  Logs = 7,             -- …/Documents/Assetto Corsa/logs
  Screenshots = 8,      -- …/Documents/Assetto Corsa/screens
  Replays = 9,          -- …/Documents/Assetto Corsa/replay
  ReplaysTemp = 10,     -- …/Documents/Assetto Corsa/replay/temp
  UserSetups = 11,      -- …/Documents/Assetto Corsa/setups
  PPFilters = 12,       -- …/SteamApps/common/assettocorsa/system/cfg/ppfilters
  ContentCars = 13,     -- …/SteamApps/common/assettocorsa/content/cars
  ContentDrivers = 14,  -- …/SteamApps/common/assettocorsa/content/drivers
  ContentTracks = 15,   -- …/SteamApps/common/assettocorsa/content/tracks
  ExtRoot = 16,         -- …/SteamApps/common/assettocorsa/extension
  ExtCfgSys = 17,       -- …/SteamApps/common/assettocorsa/extension/config
  ExtCfgUser = 18,      -- …/Documents/Assetto Corsa/cfg/extension
  ExtTextures = 21,     -- …/SteamApps/common/assettocorsa/extension/textures
  ACApps = 23,          -- …/SteamApps/common/assettocorsa/apps
  ACAppsPython = 24,    -- …/SteamApps/common/assettocorsa/apps/python
  ExtCfgState = 25,     -- …/Documents/Assetto Corsa/cfg/extension/state (changing configs there does not trigger any live reloads)
  ContentFonts = 26,    -- …/SteamApps/common/assettocorsa/content/fonts
  RaceResults = 27,     -- …/Documents/Assetto Corsa/out
  AppDataLocal = 28,    -- …/AppData/Local
  ExtFonts = 29,        -- …/SteamApps/common/assettocorsa/extension/fonts
  ACDocuments = 31,     -- …/Documents/Assetto Corsa
  ExtLua = 32,          -- …/SteamApps/common/assettocorsa/extension/lua
  ExtCache = 33,        -- …/SteamApps/common/assettocorsa/cache
  AppDataTemp = 34,     -- …/AppData/Local/Temp
  ExtInternal = 35,     -- …/SteamApps/common/assettocorsa/extension/internal
})

ac.FolderId = ac.FolderID

ac.HolidayType = __enum({ cpp = 'holiday_type' }, {
  None = 0,
  NewYear = 1,
  Christmas = 2,
  VictoryDay = 3,
  IndependenceDay = 4,
  Halloween = 5,
  JapanFestival = 6,
  ChineseNewYear = 7,
  EidAlAdha = 8,
  GuyFawkesNight = 9,
  StIstvanCelebration = 10,
  CanadaDay = 11,
  VictoriaDay = 12
})

ac.SkyRegion = __enum({ cpp = 'sky_side', passThrough = true }, {
  None = 0,
  Sun = 1,
  Opposite = 2,
  All = 3
})

ac.SkyFeature = __enum({ cpp = 'sky_feature_id' }, {
  Sun = 0,
  Moon = 1,
  Mercury = 101,
  Venus = 102,
  Mars = 103,
  Jupiter = 104,
  Saturn = 105,
  ISS = 200
})

ac.UserInputMode = __enum({ cpp = 'user_input_mode' }, {
  Wheel = 0,
  Gamepad = 1,
  Keyboard = 2
})

ac.AudioChannel = __enum({ override = 'ac.*/audioChannelKey:*', underlying = 'string' }, {
  Main = 'main',
  Rain = 'rain',
  Wind = 'wind',
  Tyres = 'tyres',
  Surfaces = 'surfaces',
  Dirt = 'dirt',
  Engine = 'engine',
  Transmission = 'transmission',
  Opponents = 'opponents',
})

ac.SpawnSet = __enum({ override = '*.*/spawnSet:*', underlying = 'string' }, {
  Start = 'START',
  Pits = 'PIT',
  HotlapStart = 'HOTLAP_START',
  TimeAttack = 'TIME_ATTACK',  -- Careful: most tracks might not have that spawn set
})

---At the moment, most of those flag types are never shown, but more flags will be added later. Also, physics-altering scripts
---(like, for example, server scripts) can override flag type and use any flag from this list (and apply their own rules and 
---penalties when needed)
ac.FlagType = __enum({ cpp = 'flag_type' }, {
  None = 0,               -- no flag, works
  Start = 1,              -- works in race, practice or hotlap modes
  Caution = 2,            -- yellow flag, works
  Slippery = 3,           -- does not work yet
  PitLaneClosed = 4,      -- does not work yet
  Stop = 5,               -- black flag, works
  SlowVehicle = 6,        -- does not work yet
  Ambulance = 7,          -- does not work yet
  ReturnToPits = 8,       -- penalty flag, works
  MechanicalFailure = 9,  -- does not work yet
  Unsportsmanlike = 10,   -- does not work yet
  StopCancel = 11,        -- does not work yet
  FasterCar = 12,         -- blue flag, works
  Finished = 13,          -- checkered flag, works
  OneLapLeft = 14,        -- white flag, works
  SessionSuspended = 15,  -- does not work yet
  Code60 = 16             -- does not work yet
})

ac.InputMethod = __enum({ cpp = 'lua_input_method' }, {
  Unknown = 0,
  Wheel = 1,
  Gamepad = 2,
  Keyboard = 3,
  AI = 4,
})

ac.PenaltyType = __enum({ cpp = 'lua_penalty_type' }, {
  None = 0,             -- No penalty
  MandatoryPits = 1,    -- Parameter: how many laps are left to do mandatory pits
  TeleportToPits = 2,   -- Parameter: how many seconds to wait in pits with locked controls
  SlowDown = 3,         -- Requires to cut gas for number of seconds in parameter (warning: works only with some race configurations, for example, “Disable gas cut penalty” should not be active in server rules settings)
  BlackFlag = 4,        -- Adds black flag, no parameter
  ReleaseBlackFlag = 5  -- Removes previously set black flag, no parameter
})

ac.ImageFormat = __enum({ cpp = 'ac_ext_image_format' }, {
  BMP = 0,
  JPG = 1,
  JPEG = 1, -- @hidden
  PNG = 2,
  DDS = 5,
  ZippedDDS = 6 -- DDS in a ZIP file, if used for saving canvas, actual saving happens in a different thread (so, it’s both fast and compact)
})

---Key indices, pretty much mirrors all those “VK_…” key tables.
ac.KeyIndex = __enum({ cpp = 'vk_key' }, { 
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
  Prior = 0x21, -- @hidden
  PageUp = 0x21, -- @opt
  Next = 0x22, -- @hidden
  PageDown = 0x22, -- @opt
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

---More types might be added later, or at least a `CustomMode` type.
ac.SessionType = __enum({ cpp = 'SessionType' }, {
  Undefined = 0,
  Practice = 1,
  Qualify = 2,
  Race = 3,
  Hotlap = 4,
  TimeAttack = 5,
  Drift = 6,
  Drag = 7,
})

ac.SharedNamespace = __enum({}, {
  Global = '',
  CarDisplay = 'car_scriptable_display',
  CarScript = 'car_script',
  TrackDisplay = 'track_scriptable_display',
  TrackScript = 'track_script',
  ServerScript = 'server_script',
  Shared = 'shared',
})

ac.CompressionType = __enum({ cpp = 'compression_type' }, {
  LZ4 = 0, -- Fastest compression, great for use in real-time applications. Does not take `level` into account.
  Deflate = 1, -- Deflate compression.
  Zlib = 2, -- Zlib compression (deflate with zlib wrapper).
  Gzip = 3 -- Gzip compression (deflate with gzip wrapper).
})

ac.NationCode = __enum({ override = '*.*/nationCode:string', underlying = 'string' }, {
  --[[? out($.readText(`${process.env['AC_ROOT']}/extension/config/data_countries.ini`).split('\n')
    .map(x => /(\w+)=(.+)/.test(x) && [RegExp.$1, RegExp.$2]).filter(x => x)
    .map(x => `${x[1].replace(/\W+/g, _ => ({'ô':'o'})[_] || $.fail(`Unexpected symbol: ${_}`))} = "${x[0]}", -- ${x[1]}`).join('\n')) ?]]
})

ac.CSPModuleID = __enum({ override = '*.*/cspModuleID:string', underlying = 'string' }, {
  --[[? out(fs.readdirSync(`${process.env['AC_ROOT']}/extension/config`).filter(x => /^(?!data_|module_).+\.ini$/.test(x))
    .map(x => {
      const i = x.replace(/\.ini$/, '');
      const d = i.replace(/(?:^|_)([a-z])/g, (_, a) => a.toUpperCase()).replace(/Fx|Dxgi|Gui|Ffb|Vr/, _ => _.toUpperCase())
        .replace(/Neck/, 'NeckFX').replace(/Brakedisc/, 'BrakeDisc');
      const n = /FULLNAME\s*=\s*(.+)/.test($.readText(`${process.env['AC_ROOT']}/extension/config/${x}`)) ? RegExp.$1 : i;
      return `${d} = "${i}", -- ${n}`
    }).join('\n')) ?]]
  JoypadAssist = 'gamepad_fx' -- @hidden
})

ac.ObjectClass = __enum({ }, {
  Any = 0,  -- return any scene object. If returned as result from `:class()`, means that there is no object with such index.
  Node = 1,  -- regular children-holding objects.
  Model = 2,  -- track objects
  CarNodeSorter = 3,  -- an object holding cars
  NodeBoundingSphere = 4,  -- a wrapper for each car, skipping rendering if whole thing is not in frustum

  NodeEvent = 6,  -- @hidden
  IdealLine = 7,  -- ideal line
  ParticleSystem = 8,  -- particle systems (don’t do much with ParticlesFX active)
  StaticParticleSystem = 9,  -- usually used for spectators
  DisplayNode = 10,  -- display nodes for car dashboards
  TextNode = 11,  -- 3D text nodes for car dashboards
  CSPNode = 12,  -- CSP nodes, for example fake shadow nodes

  Renderable = 13,  -- refers to meshes and skinned meshes together
  Mesh = 15,  -- regular meshes
  SkinnedMesh = 16,  -- skinned meshes
  SkidmarkBuffer = 17,  -- objects with skidmarks (don’t do much with SkidmarksFX active)
})

ac.GamepadButton = __enum({ override = '*.*/gamepadButtonID:integer' }, {
  DPadUp = 0x1,
  DPadDown = 0x2,
  DPadLeft = 0x4,
  DPadRight = 0x8,
  Start = 0x10,
  Back = 0x20,
  LeftThumb = 0x40,
  RightThumb = 0x80,
  LeftShoulder = 0x100,
  RightShoulder = 0x200,
  L2 = 0x400,  -- only for DualShock and Nintendo (ZL) gamepads
  R2 = 0x800,  -- only for DualShock and Nintendo (ZR) gamepads
  A = 0x1000,
  B = 0x2000,
  X = 0x4000,
  Y = 0x8000,
  PlayStation = 0x10000, -- only for DualShock, DualSense and Nintendo (Home button) gamepads
  Microphone = 0x20000, -- only for DualSense and Nintendo (SL button) gamepads
  Pad = 0x40000, -- only for DualShock, DualSense and Nintendo (Capture button) gamepads
  Extra = 0x80000, -- only for Nintendo (SR button) gamepads
})

ac.GamepadAxis = __enum({ override = '*.*/gamepadAxisID:integer' }, {
  LeftTrigger = 0,
  RightTrigger = 1,
  LeftThumbX = 2,
  LeftThumbY = 3,
  RightThumbX = 4,
  RightThumbY = 5
})

ac.GamepadType = __enum({ cpp = 'joypad_type' }, {
  None = 0, -- No gamepad in that slot.
  XBox = 1, -- Regular XBox gamepad.
  DualSense = 2, -- DualSense gamepad.
  DualShock = 3, -- DualShock gamepad (can also be one of Nintendo gamepads; use `ac.getDualShock(…).type` to check).
})

---Due to compatibility issues DualShock and Nintendo devices are combined in an alternative API area separately from DualSense.
ac.GamepadDualShockType = __enum({ cpp = 'dualshock_device_type' }, {
  JoyConLeft = 1, -- Left Joy-Con
  JoyConRight = 2, -- Right Joy-Con
  SwitchPro = 3, -- Switch Pro Controller
  DualShock = 4, -- DualShock 4
  DualSense = 5, -- DualSense (can appear here if controller is configured to launch in DualShock mode in CM controls settings)
})
