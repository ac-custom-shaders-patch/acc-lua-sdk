__source 'lua/api_secure.cpp'

function __script.__secure__()
  __script.__secure__ = nil

  local charPtr = ffi.typeof('char*')

  --[[ 
    Disable some FFI features. Full list:
      abi = { type = "function", name = "nil", source = "=[C]", what = "C" },
      alignof = { type = "function", name = "nil", source = "=[C]", what = "C" },
      arch = "x64",
      cast = { type = "function", name = "nil", source = "=[C]", what = "C" },
      cdef = { type = "function", name = "nil", source = "=[C]", what = "C" },
      copy = { type = "function", name = "nil", source = "=[C]", what = "C" },
      errno = { type = "function", name = "nil", source = "=[C]", what = "C" },
      fill = { type = "function", name = "nil", source = "=[C]", what = "C" },
      gc = { type = "function", name = "nil", source = "=[C]", what = "C" },
      istype = { type = "function", name = "nil", source = "=[C]", what = "C" },
      load = { type = "function", name = "nil", source = "=[C]", what = "C" },
      metatype = { type = "function", name = "nil", source = "=[C]", what = "C" },
      new = { type = "function", name = "nil", source = "=[C]", what = "C" }
      offsetof = { type = "function", name = "nil", source = "=[C]", what = "C" },
      os = "Windows",
      sizeof = { type = "function", name = "nil", source = "=[C]", what = "C" },
      string = { type = "function", name = "nil", source = "=[C]", what = "C" },
      typeinfo = { type = "function", name = "nil", source = "=[C]", what = "C" },
      typeof = { type = "function", name = "nil", source = "=[C]", what = "C" },
  ]]
  ffi = {
    abi = _F.abi,
    -- cast = _F.cast,
    -- copy = _F.copy,
    -- fill = _F.fill,
    -- gc = _F.gc,
    string = function (ptr, len)
      if not _F.istype(charPtr, ptr + 0) then error('Not allowed', 2) end
      return _F.string(ptr, len)
    end,
    alignof = _F.alignof,
    errno = _F.errno,
    istype = _F.istype,
    offsetof = _F.offsetof,
    sizeof =_F.sizeof,
    -- typeinfo = _F.typeinfo,
    typeof = _F.typeof,
    arch = 'x64',
    os = 'Windows',
  }

  -- Remove everything from debug module
  table.clear(debug)

  -- Just a small precaution
  collectgarbage = function () return 0 end
  -- string.dump = function () return nil end

  -- Add filter to io.open: no writing, reading allowed files only
  local _iopen, _iinput, _ilines = io.open, io.input, io.lines
  function io.open(filename, mode)
    if mode ~= 'r' and mode ~= 'rb' or not ffi.C.lj_is_file_allowed(filename) then return nil, 'Not allowed' end
    return _iopen(filename, mode), nil
  end

  function io.input(filename) 
    if type(filename) ~= 'string' or not ffi.C.lj_is_file_allowed(filename) then error('Not allowed', 1) end
    return _iinput(filename)
  end

  -- Similar check for io.lines
  function io.lines(filename)
    return ffi.C.lj_is_file_allowed(filename) and _ilines(filename) or function () return nil end
  end

  -- Replace some other io functions by dummies
  io.stdin = nil
  io.stdout = nil
  io.stderr = nil
  function io.output() error('Not allowed', 1) end
  function io.tmpfile() return nil end
  function io.popen() return nil end
  function io.flush() end

  -- Replace some os functions by dummies
  function os.execute() return -1 end
  function os.exit() end
  function os.getenv() return nil end
  function os.setlocale() return nil end
  function os.remove() return nil, 'Not allowed' end
  function os.rename() return nil, 'Not allowed' end
  function os.tmpname() return nil end

  -- Make sure require would not be able to load DLLs
  function package.loadlib() end
  package.loaders = {package.loaders[1], package.loaders[2]}
  package.preload.ffi = nil

  -- A bit of protection for dofile/load/loadfile
  local _dofile = dofile
  function dofile(filename)
    if filename == nil or not ffi.C.lj_is_file_allowed(filename) then error('Not allowed', 2) end
    return _dofile(filename), nil
  end

  local _loadfile = loadfile
  function loadfile(filename, mode, env)
    if mode == 'b' or filename == nil or not ffi.C.lj_is_file_allowed(filename) then return nil, 'Not allowed' end
    return _loadfile(filename, 't', env), nil
  end

  local _load = load
  function load(chunk, chunkname, mode, env)
    if mode == 'b' then return nil, 'Not allowed' end
    return _load(chunk, chunkname, 't', env), nil
  end

  -- Secure loadstring 
  local _loadstring = loadstring
  function loadstring(s, c) 
    if type(s) ~= 'string' or string.byte(s) == 27 or string.byte(s) == 6 then return nil, 'Not allowed' end
    return _loadstring(s, c), nil
  end

  if ac.StructItem then
    local _sicdef = __util.__si_cdef
    __util.__si_cdef = function(layout, compact)
      if string.find(layout, '*', 1, true) then error('Not allowed', 3) end
      return _sicdef(layout, compact)
    end
  end

  local _stfs = ac.stringToFFIStruct
  ac.stringToFFIStruct = function (src, dst, size)
    if not _F.istype(charPtr, dst + 0) then error('Not allowed', 2) end
    return _stfs(src, dst, size)
  end
end
