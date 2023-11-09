-- For acc-lua only, does not get copied to final library or definitions.

__source = function(name) end
__states = function(name) end
__allow = function(name) end
__namespace = function(name) end

---@param cb function
__post_cdef = function(cb) end

__definitions = function(arg) end
__enum = function(params, values) end
__carindex__ = 0
__cfgSection__ = 0
__mode__ = nil

ffi = {}
newproxy = nil