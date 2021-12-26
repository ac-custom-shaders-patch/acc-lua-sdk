ac.FogAlgorithm = __enum({ cpp = 'fog_algorithm' }, { 
  Original = 0,
  New = 1
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

ac.LightsDebugMode = __enum({ cpp = 'lights_debug_mode' }, { 
  Off = 0,
  Outline = 1,
  BoundingBox = 2,
  BoundingSphere = 4,
  Text = 8,
})

ac.VAODebugMode = __enum({ cpp = 'vao_mode' }, { 
  Active = 1,
  Inactive = 3,
  VAOOnly = 4,
  ShowNormals = 5
})

ac.Wheel = __enum({ cpp = 'ac_wheel' }, { 
  FrontLeft = 1,
  FrontRight = 2,
  RearLeft = 4,
  RearRight = 8,

  Front = 3,
  Rear = 12,
  Left = 5,
  Right = 10,
  
  All = 15
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
  LogLum = 6          -- saturation retention type logarithmic space tone map function
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
  ACDocuments = 31      -- …/Documents/Assetto Cors
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
  GuyFawkesNight = 9
})

ac.SkyRegion = __enum({ cpp = 'sky_side', passThrough = true }, {
  None = 0,
  Sun = 1,
  Opposite = 2,
  All = 3
})

ac.AudioChannel = __enum({ override = 'ac.*/audioChannelKey:*', underlying = 'string' }, {
  Main = 'main',
  Rain = 'rain',
})

ac.SpawnSet = __enum({ override = '*.*/spawnSet:*', underlying = 'string' }, {
  Start = 'START',
  Pits = 'PIT',
  HotlapStart = 'HOTLAP_START',
  TimeAttack = 'TIME_ATTACK',  -- Careful: most tracks might not have that spawn set
})

---At the moment, most of those flag types are never shown, but more flags will be added later.
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
