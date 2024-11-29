__source 'lua/api_physics_bw.cpp'
__namespace 'physics'

--[[? ctx.flags.physicsThread = true; ?]]
require './common/internal_import'
require './common/ac_extras_binaryinput'
require './common/secure'

physics = {}

-- automatically generated entries go here:
__definitions()

---Nothing from here will be called for background threads.
---@class ScriptData
---@single-instance
script = {}

worker = setmetatable({}, {
  __index = function (s, key)
    if key == 'input' then return __input end
    if key == 'terminate' then return __util.__terminate end
  end,
})
