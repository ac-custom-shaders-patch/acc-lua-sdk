__source 'lua/api_common_debug.cpp'

--[[? if (ctx.ldoc) out(]]

---Prints a message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.log(...)
  -- ffi.C.lj_log_inner(_logargs(', ', ...))
end

---Prints a warning message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.warn(...)
  -- ffi.C.lj_warn_inner(_logargs(', ', ...))
end

---Prints an error message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
---@param ... string|number|boolean @Values.
function ac.error(...)
  -- ffi.C.lj_error_inner(_logargs(', ', ...))
end

---For compatibility, acts similar to `ac.log()`.
function print(...)
  -- ffi.C.lj_log_inner(_logargs(' ', ...))
end

--[[); else out(]]

print = ac.log

--[[) ?]]