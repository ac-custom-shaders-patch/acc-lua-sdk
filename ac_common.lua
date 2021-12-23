__source 'lua/api_common.cpp'

ac = {}

-- a simple wrapper for creating new classes, similar to middleclass (check that file for more info)
require './common/class'

-- all sorts of modules:
require 'ffi'
require './deps/vector'
require './common/common'
require './common/ac_primitive'
require './common/ac_matrices'
require './common/ac_ro_vectors'
require './common/function'
require './common/math'
require './common/string'
require './common/table'
require './common/internal'
require './common/internal_import'
require './common/io'
require './common/os'
require './common/timer'
require './common/ac_enums'
require './common/ac_extras_connect'
require './common/ac_extras_hashspace'
require './common/ac_extras_numlut'
require './common/ac_extras_onlineevent'
require './common/ac_general_utils'
require './common/ac_state'
require './common/ac_storage'
require './common/ac_configs'
require './common/ac_reftypes'
require './common/ac_web'
require './common/stringify'

-- automatically generated entries go here:
__definitions()
