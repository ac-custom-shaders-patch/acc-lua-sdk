---Structure containing various file or directory attributes, including various flags and dates. All values are precomputed and ready to be used (there is
---no overhead in accessing them once you get the structure).
---@class io.FileAttributes
---@field fileSize integer @File size in bytes.
---@field creationTime integer @File creation time in seconds from 1970.
---@field lastAccessTime integer @File last access time in seconds from 1970.
---@field lastWriteTime integer @File last write time in seconds from 1970.
---@field exists boolean @True if file exists.
---@field isDirectory boolean @True if file is a directory.
---@field isHidden boolean @The file or directory is hidden. It is not included in an ordinary directory listing.
---@field isReadOnly boolean @A file that is read-only. Applications can read the file, but cannot write to it or delete it.
---@field isEncrypted boolean @A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
---@field isCompressed boolean @A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
---@field isReparsePoint boolean @A file or directory that has an associated reparse point, or a file that is a symbolic link.
---@cpptype lua_file_attributes
local _fileAttributes = {}
