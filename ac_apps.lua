__source 'extensions/lua_tools/ac_ext_lua_tools.cpp'
__allow 'luatools'

require './common/internal_import'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_scene'
require './common/ac_physics'
require './common/ac_game'
require './common/ac_car_control'
require './common/ac_apps'

---Draw virtual mirror.
---@param pos vec2
---@param size vec2
---@param color rgbm? @Default value: `rgbm.colors.white`.
function ui.drawVirtualMirror(pos, size, color)
  ui.drawImage('dynamic::mirror', pos, size, color, vec2(1, 0), vec2(0, 1))
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
