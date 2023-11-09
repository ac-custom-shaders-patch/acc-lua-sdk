ac.PhysicsDebugLines = __enum({ cpp = 'phys_debug_lines_switches' }, { 
  None = 0,
  Tyres = 1,         -- Tyres raycasting
  WetSkidmarks = 2,  -- Marks left by tyres reducing grip in rain
  Script = 4,        -- Lines drawn by custom physics script
  RainLane = 65536,  -- Alternative AI lane for rain
})

ac.LightsDebugMode = __enum({ cpp = 'lights_debug_mode' }, { 
  Off = 0, -- @hidden
  None = 0,
  Outline = 1,
  BoundingBox = 2,
  BoundingSphere = 4,
  Text = 8,
})

ac.VRSRateMode = __enum({ cpp = 'vrs_rate_mode' }, { 
  X0 = 0,
  X16 = 1,
  X8 = 2,
  X4 = 3,
  X2 = 4,
  X1 = 5,
  X1_2X1 = 6,
  X1_1X2 = 7,
  X1_2X2 = 8,
  X1_4X2 = 9,
  X1_2X4 = 10,
  X1_4X4 = 11,
})

ac.VAODebugMode = __enum({ cpp = 'vao_mode' }, { 
  Active = 1,
  Inactive = 3,
  VAOOnly = 4,
  ShowNormals = 5
})

ac.ScreenshotFormat = __enum({ cpp = 'screenshot_format' }, {
  Auto = 0, -- As configured in AC system settings
  BMP = 1,
  JPG = 2,
  JPEG = 2,
  PNG = 3,
  DDS = 4,
})

ac.SceneTweakFlag = __enum({}, {
  Default = 0,
  ForceOn = 1,
  ForceOff = 2,
})

ac.CarControlsInput = {}

ac.CarControlsInput.Flag = __enum({}, {
  Skip = -1,
  Disable = 0,
  Enable = 1
})
