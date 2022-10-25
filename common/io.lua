--[[? if (!ctx.test) out(]]
__source 'lua/api_io.cpp'
__namespace 'io'
--[[) ?]]

ffi.cdef[[ 

typedef struct { 
  int64_t fileSize;
  int64_t creationTime;
  int64_t lastAccessTime;
  int64_t lastWriteTime;
  bool exists;
  bool isDirectory;
  bool isHidden;
  bool isReadOnly;
  bool isEncrypted;
  bool isCompressed;
  bool isReparsePoint;
} lua_file_attributes; 

typedef struct { 
  lua_string_ref name__;
  int64_t fileSize;
  int64_t creationTime;
  int64_t lastAccessTime;
  int64_t lastWriteTime;
  bool exists;
  bool isDirectory;
  bool isHidden;
  bool isReadOnly;
  bool isEncrypted;
  bool isCompressed;
  bool isReparsePoint;
} lua_dir_scan; 

]]

---Reads file content into a string, if such file exists, otherwise returns fallback data or `nil`.
---@param filename string @Filename.
---@param fallbackData string|nil @Data to return if file could not be read.
---@return string|nil @Returns `nil` if file couldn’t be read and there is no fallback data.
function io.load(filename, fallbackData)
  return __util.strrefp(ffi.C.lj_load_inner__io(filename)) or fallbackData
end

---Scan directory and call callback function for each of files, passing file name (not full name, but only name of the file) and attributes. If callback function would return
---a non-nil value, iteration will stop and value returned by callback would return from this function. This could be used to
---find a certain file without going through all files in the directory. Optionally, a mask can be used to pre-filter received files
---entries.
---
---If callback function is not provided, it’ll return list of files instead (file names only).
---
---System entries “.” and “..” will not be included in the list of files. Accessing attributes does not add extra cost.
---@generic TCallbackData
---@generic TReturn
---@param directory string @Directory to look for files in. Note: directory is relative to current directory, not to script directory. For AC in general it’s an AC root directory, but do not rely on it, instead use `ac.getFolder(ac.FolderID.Root)`.
---@param mask string? @Mask in a form of usual “*.*”. Default value: '*'.
---@param callback fun(fileName: string, fileAttributes: io.FileAttributes, callbackData: TCallbackData): TReturn @Callback which will be ran for every file in directory fitting mask until it would return a non-nil value.
---@param callbackData TCallbackData? @Callback data that will be passed to callback as third argument, to avoid creating a capture.
---@return TReturn @First non-nil value returned by callback.
---@overload fun(directory: string, callback: fun(fileName: string, fileAttributes: io.FileAttributes, callbackData: any), callbackData: any): any
---@overload fun(directory: string, mask: string|nil): string[]
function io.scanDir(directory, mask, callback, callbackData)
  if type(directory) ~= 'string' then error('First argument has to be a string with path to a directory', 2) end
  if type(mask) == 'function' then mask, callback, callbackData = nil, mask, callback end
  local s, r = ffi.C.lj_dirscan_start__io(__util.str(directory), __util.str_opt(mask)), nil
  if not callback then
    r = {}
    local n = 1
    while s.exists do
      r[n], n = __util.strrefr(s.name__), n + 1
      ffi.C.lj_dirscan_next__io(s)
    end
  else
    r = nil
    while s.exists do
      r = callback(__util.strrefr(s.name__), s, callbackData)
      if r ~= nil then break end
      ffi.C.lj_dirscan_next__io(s)
    end
  end
  ffi.C.lj_dirscan_end__io(s)
  return r
end

---Returns list of logical drives, each drive in “A:“ format.
---@return string[]
function io.scanDrives()
  local i = ffi.C.lj_scanDrives_inner__io()
  local j, r = 0, {}
  while j < 25 do
    if bit.band(i, bit.lshift(1, j)) ~= 0 then
      r[#r + 1] = string.char(65 + j)..':'
    end
    j = j + 1
  end
  return r
end

local _szr
__script.scanZipCallback = function (s) _szr = s end

---Returns list of entry names from a ZIP-file.
---@param filename string
---@return string[]
function io.scanZip(filename)
  _szr = nil
  ffi.C.lj_scanZip_inner__io(filename)
  return _szr or {}
end
