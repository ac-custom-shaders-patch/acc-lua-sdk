__source 'extensions/neck/ac_ext_neck.cpp'

require './common/internal_import'
require './common/ac_audio'
require './wfx_common/ac_weatherconditions'

ac.CockpitCameraMode = __enum({}, {
  Base = 0, -- Regular mode (or a mode with connected TrackIR which hasn’t moved yet)
  IR = 1,   -- TrackIR mode (input `neck` position and orientation is already offset)
  VR = 2,   -- VR mode (better to do the absolute minimum there, only some sort of G-forces reaction)
})

-- automatically generated entries go here:
__definitions()

-- extra additions:

---Reference to information about state of associated car.
---@type ac.StateCar
car = nil

---Reference to information about state of simulation.
---@type ac.StateSim
sim = nil

---Reference to camera transformation. Alter its `look`, `up` and `position` to move the camera.
---@type mat4x4
neck = nil

function __script.updateState(carIndex)
  if not car or car.index ~= carIndex then
    car = ac.getCar(carIndex)
    if not sim then
      sim = ac.getSim()
      neck = ffi.C.lj_access_neck_data()
    end
  end
end

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each frame.
---@param dt number @Time passed since last `update()` call, in seconds.
---@param mode ac.CockpitCameraMode @Current mode. Mostly for checking if VR is active and stopping extra rotation if so.
---@param turnMix number @How much to turn head willingly (goes to 0 with TrackIR or mouse camera rotation)
function script.update(dt, mode, turnMix) end

--[[) ?]]
