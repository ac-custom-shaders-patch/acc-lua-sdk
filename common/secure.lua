__source 'lua/api_secure.cpp'

-- Disable adding new FFI bindings
ffi.C = nil

-- Remove everything from debug module
table.clear(debug)

-- Disable io.popen
function io.popen() return nil end

-- Add filter to io.open: no writing, reading allowed files only
local _iopen, _ilines = io.open, io.lines
function io.open(filename, mode)
  if mode ~= 'r' and mode ~= 'rb' or not ffi.C.lj_is_file_allowed(filename) then return nil, 'Not allowed' end
  return _iopen(filename, mode)
end

-- Similar check for io.lines
function io.lines(filename)
  return ffi.C.lj_is_file_allowed(filename) and _ilines(filename) or function () return nil end
end

-- Replace some os functions by dummies
function os.execute() return -1 end
function os.exit() end
function os.getenv() return nil end
function os.setlocale() return nil end
function os.remove() return nil, 'Not allowed' end
function os.rename() return nil, 'Not allowed' end

-- Make sure require would not be able to load DLLs
function package.loadlib() end
package.loaders = {package.loaders[1], package.loaders[2]}
package.preload.ffi = nil

-- A bit of protection for dofile/load/loadfile
local _dofile = dofile
function dofile(filename)
  if filename == nil or not ffi.C.lj_is_file_allowed(filename) then error('Not allowed', 2) end
  return _dofile(filename)
end

local _loadfile = loadfile
function loadfile(filename, mode, env)
  if mode == 'b' or filename == nil or not ffi.C.lj_is_file_allowed(filename) then return nil, 'Not allowed' end
  return _loadfile(filename, 't', env)
end

local _load = load
function load(chunk, chunkname, mode, env)
  if mode == 'b' then return nil, 'Not allowed' end
  return _load(chunk, chunkname, 't', env)
end
