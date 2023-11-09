__source 'extensions/lua_tools/ac_ext_lua_tools.cpp'
__allow 'luatools'

--[[? ctx.flags.withPhysics = true; ?]]

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_particles'
require './common/ac_physics'
require './common/ac_physics_ai'
require './common/ac_gameplay'
require './common/ac_game'
require './common/ac_game_apps'
require './common/ac_track_conditions'
require './common/ac_car_control'
require './common/ac_car_control_switch'
require './common/ac_apps'
require './common/ac_extras_backgroundworker'
require './wfx_common/ac_weatherconditions'
-- require './common/ac_extras_leapmotion'

---Draw virtual mirror. If Real Mirrors module is active and has its virtual mirrors option enabled, mirror might be drawn in two pieces 
---taking less space width-wise (for cars without middle mirror) or just drawn narrower. If that option is disabled, Real Mirrors will pause.
---@param p1 vec2
---@param p2 vec2
---@param color rgbm? @Default value: `rgbm.colors.white`.
---@return boolean @Returns `false` if there is no virtual mirror currently available.
function ui.drawVirtualMirror(p1, p2, color)
  local p = ffi.C.lj_getRealMirrorVirtualPieces_inner__carc(p1, p2)
  if p ~= nil then
    if p[0].x < 1e9 then
      ui.drawImage('dynamic::mirror', p[0], p[1], color, p[2], p[3])
    elseif p[4].x > 1e9 then
      return false
    end
    if p[4].x < 1e9 then
      ui.drawImage('dynamic::mirror', p[4], p[5], color, p[6], p[7])
    end
  else
    ui.drawImage('dynamic::mirror', p1, p2, color, vec2(1, 0), vec2(0, 1))
  end
  return true
end

local _sslv, _ssrn

---Collect information about available spinners in setup menu. Names match section names of setup INI files. Value `label` might contain localized setup items.
---@return {name: string, label: string, min: integer, max: integer, step: integer, value: integer, displayMultiplier: number, readOnly: boolean, units: string?, items: string[]?, defaultValue: integer?, showClicksMode: integer?}[]
function ac.getSetupSpinners()
  if not _ssrn then _ssrn = refnumber() end
  ffi.C.lj_getSetupSpinners_inner__apps(_ssrn)
  _sslv = __util.result() or _sslv
  return _sslv or error('Failed to get data', 2)
end

-- automatically generated entries go here:
__definitions()

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each frame.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

--[[) ?]]
