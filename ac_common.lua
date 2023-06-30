__source 'lua/api_common.cpp'

-- a simple wrapper for creating new classes, similar to middleclass (check that file for more info)
require './common/class'

-- all sorts of modules:
require 'ffi'
require './common/debug'
require './common/common'
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
require './deps/vector'
require './common/io'
require './common/os'
require './common/timer'
require './common/ac_enums'
require './common/ac_extras_ini'
require './common/ac_extras_datalut'
require './common/ac_extras_connect'
require './common/ac_extras_hashspace'
require './common/ac_extras_numlut'
require './common/ac_extras_onlineevent'
require './common/ac_extras_connectmmf'
require './common/ac_general_utils'
require './common/ac_social'
require './common/ac_music'
require './common/ac_state'
require './common/ac_storage'
require './common/ac_configs'
require './common/ac_reftypes'
require './common/ac_dualsense'
require './common/ac_dualshock'
require './common/ac_web'
require './common/ac_cdef_definitions'
require './common/stringify'
require './common/json'

require './common/ac_primitive_vec2.d'
require './common/ac_primitive_vec3.d'
require './common/ac_primitive_vec4.d'
require './common/ac_primitive_rgb.d'
require './common/ac_primitive_hsv.d'
require './common/ac_primitive_rgbm.d'
require './common/ac_primitive_quat.d'

-- automatically generated entries go here:
__definitions()
