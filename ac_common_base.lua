__source 'lua/api_common.cpp'

-- a simple wrapper for creating new classes, similar to middleclass (check that file for more info)
require './common/class'

io = {}
os = {}

--[[? if (ctx.ldoc) out(]]

ui = {}

--[[) ?]]

-- all sorts of modules:
require 'ffi'
require './common/debug'
require './common/common_base'
require './common/const'
require './common/ac_primitive'
require './common/ac_matrices'
require './common/ac_ro_vectors'
require './common/function'
require './common/math'
require './common/string'
require './common/table'
require './common/internal'
require './common/internal_import'

require './common/ac_enums'
require './common/ac_audio_enums'
require './common/ac_game_enums'
require './common/ac_joypad_assist_enums'
require './common/ac_render_enums'
require './common/ac_ui_enums'

require './common/ac_extras_ini'
require './common/ac_extras_datalut'
require './common/ac_extras_connect'
require './common/ac_reftypes'
require './common/ac_weatherconditions'
require './common/ac_state'
require './common/stringify'
require './common/json'
require './common/secure'

-- automatically generated entries go here:
__definitions('nodocs')

function __script.__initbase__()
  __script.__secure__()
  if __mode__ == 'car_cphys' or __mode__ == 'car_scriptable_display' or __mode__ == 'car_script' then
    car = ac.getCar(__carindex__ - 1)
  end
end

local gt = getmetatable(_G) or {}
gt.__index = function(_, key) error('Undefined variable: '..key, 2) end
setmetatable(_G, gt)
