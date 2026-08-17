__source 'lua/api_common_debug.cpp'

--[[? if (ctx.ldoc) out(]]

---Prints a message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
function ac.log(...) end

---Prints a warning message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
function ac.warn(...) end

---Prints an error message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.
function ac.error(...) end

---For compatibility, acts similar to `ac.log()`.
function print(...) end

--[[); else out(]]

print = ac.log

--[[) ?]]