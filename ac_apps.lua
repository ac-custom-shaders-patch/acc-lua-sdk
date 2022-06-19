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
require './common/ac_gameplay'
require './common/ac_game'
require './common/ac_car_control'
require './common/ac_apps'
-- require './common/ac_extras_leapmotion'

---Draw virtual mirror.
---@param pos vec2
---@param size vec2
---@param color rgbm? @Default value: `rgbm.colors.white`.
function ui.drawVirtualMirror(pos, size, color)
  ui.drawImage('dynamic::mirror', pos, size, color, vec2(1, 0), vec2(0, 1))
end

local _sslv, _ssrn

---Collect information about available spinners in setup menu. Names match section names of setup INI files. Value `label` might contain localized setup items.
---@return {name: string, label: string, min: integer, max: integer, step: integer, value: integer, readOnly: boolean, units: string?, items: string[]?, defaultValue: integer?, showClicksMode: integer?}[]
function ac.getSetupSpinners()
  if not _ssrn then _ssrn = refnumber() end
  ffi.C.lj_getSetupSpinnerIDs_inner__apps(_ssrn)
  _sslv = __getResult__() or _sslv
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
