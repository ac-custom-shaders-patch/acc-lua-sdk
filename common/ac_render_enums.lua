---Render namespace for drawing custom shapes and other stuff like that.
render = {}

render.PassID = __enum({ cpp = 'render_callback_pass_id' }, {
  None = 0,
  Main = 1,
  Mirror = 2,
  CubeMap = 4,
  Extras = 8,
  All = 15
})

render.BlendMode = __enum({ cpp = 'AC::BlendMode', max = 25 }, {
  Opaque = 0,
  AlphaBlend = 1,
  AlphaTest = 2,
  BlendAdd = 4,
  BlendMultiply = 5,
  BlendSummingAlpha = 1, --@hidden
  BlendSubtract = 12,
  BlendAccurate = 13,
  BlendPremultiplied = 14,
})

render.CullMode = __enum({ cpp = 'AC::CullMode', max = 11 }, {
  Front = 0,
  Back = 1,
  None = 2,
  Wireframe = 4,
  WireframeAntialised = 7,
  ShadowsDouble = 9,
  ShadowsSingle = 10,
})

render.DepthMode = __enum({ cpp = 'AC::DepthMode', max = 5 }, {
  Normal = 0,
  ReadOnly = 1,
  Off = 2,
  LessEqual = 3,
  ReadOnlyLessEqual = 4
})

render.GLPrimitiveType = __enum({ cpp = 'AC::GLPrimitiveType', max = 5 }, {
  Lines = 0,
  LinesStrip = 1,
  Triangles = 2,
  Quads = 3
})

render.FontAlign = __enum({ cpp = 'AC::FontAlign', max = 2 }, {
  Left = 0,
  Right = 1,
  Center = 2
})

render.ShadersType = __enum({ cpp = 'shaders_type' }, {
  Main = 0,                   -- With lights and advanced version of shaders (when possible, consider using SimplifiedWithLights instead)
  Simplified = 13,            -- Used by reflections and mirrors, without lights
  SimplifiedWithLights = 14,  -- Used by reflections and mirrors, with lights
  Simplest = 16,              -- The most basic option, without lights
  SampleColor = 18,           -- Get diffuse color as accurate as possible
  SampleNormal = 19,          -- Get surface normal in world space
  SampleEmissive = 20,        -- Get emissive color
  Shadows = 0,                -- @deprecated If you want cool looks, use `Main` instead, this was originally meant to draw shadow maps, but due to some general issues isn’t working as intended, and for actual shadows use `SampleDepth`
  SampleDepth = 27,           -- Efficient option for generating depth map without wasting time on drawing the image, doesn’t update the main color texture (only meshes casting shadows are included)
})

---These flags can be combined together with `bit.bor()`.
render.TextureMaskFlags = __enum({ cpp = 'ri_mask_flags' }, {
  Default = 6,              -- Default: use alpha and red channel as multipliers
  UseColorAverage = 1,      -- Use average of RGB values
  UseAlpha = 2,             -- Use alpha of a mask as a multiplier
  UseRed = 4,               -- Use red channel of a mask as a multiplier
  UseGreen = 8,             -- Use green channel of a mask as a multiplier
  UseBlue = 16,             -- Use blue channel of a mask as a multiplier
  UseInvertedAlpha = 32,    -- Use inverted alpha of a mask as a multiplier
  UseInvertedRed = 64,      -- Use inverted red channel of a mask as a multiplier
  UseInvertedGreen = 128,   -- Use inverted green channel of a mask as a multiplier
  UseInvertedBlue = 256,    -- Use inverted blue channel of a mask as a multiplier
  MixColors = 512,          -- Use colors of a mask as a multiplier for main colors
  MixInvertedColors = 1024, -- Use inverted colors of a mask as a multiplier for main colors
  AltUV = 65536,            -- Use alternative UV (for projecting textures onto meshes, uses original mesh UV instead of projection UV)
})

render.AntialiasingMode = __enum({ cpp = 'aa_mode' }, {
  None = 0,  -- No antialiasing
  FXAA = 101,  -- Blurry and slower than CMAA
  CMAA = 102,  -- Faster and sharper option comparing to FXAA
  ExtraSharpCMAA = 103, -- Like CMAA, but even sharper
  YEBIS = 104, -- Applies YEBIS antialiasing together with the whole filtering HDR→LDR conversion using main PP settings. Note: first run for each resolution can take a lot of time. Each resolution creates its own YEBIS post-processing step, with many different resolutions things might get too expensive.
})

render.TextureFormat = __enum({ cpp = 'uirt_format' }, {
  R32G32B32A32 = { Float = 2, UInt = 3, SInt = 4 },
  R32G32B32 = { Float = 6, UInt = 7, SInt = 8 },
  R32G32 = { Float = 16, UInt = 17, SInt = 18 },
  R32 = { Float = 41, UInt = 42, SInt = 43 },
  R16G16B16A16 = { Float = 10, UNorm = 11, UInt = 12, SNorm = 13, SInt = 14 },
  R16G16 = { Float = 34, UNorm = 35, UInt = 36, SNorm = 37, SInt = 38 },
  R16 = { Float = 54, UNorm = 56, UInt = 57, SNorm = 58, SInt = 59 },
  R10G10B10A2 = { UNorm = 24, UInt = 25 },
  R11G11B10 = { Float = 26 },
  R8G8B8A8 = { UNorm = 28, UInt = 30, SNorm = 31, SInt = 32 },
  R8G8 = { UNorm = 49, UInt = 50, SNorm = 51, SInt = 52 },
  R8 = { UNorm = 61, UInt = 62, SNorm = 63, SInt = 64 },
  R1 = { UNorm = 66 },
})

render.TextureFlags = __enum({}, {
  None = 0,
  Shared = 1,  -- Shared texture (D3D11_RESOURCE_MISC_SHARED)
})