---@diagnostic disable: redundant-parameter

__source 'lua/api_extras_ini.cpp'

ac.INIFormat = __enum({}, {
  Default = 0, -- AC format: no quotes, “[” in value begins a new section, etc.
  DefaultAcd = 1, -- AC format, but also with support for reading files from `data.acd` (makes difference only for `ac.INIConfig.load()`).
  Extended = 10, -- Quotes are allowed, comma-separated value turns into multiple values (for vectors and lists), repeated keys replace previous values.
  ExtendedIncludes = 11, -- Same as CSP, but also with support for INIpp expressions and includes.
})

ac.INIConfig = class('ac.INIConfig', function (format, sections, filename)
  return { format = format or 0, sections = sections or {}, filename = filename }
end)

---Pass this as a `defaultValue` to `:get()` (or use it as a value in `:mapSection()`) to get either a boolean or, if it’s missing, `nil`.
ac.INIConfig.OptionalBoolean = {}

---Pass this as a `defaultValue` to `:get()` (or use it as a value in `:mapSection()`) to get either a number or, if it’s missing, `nil`.
ac.INIConfig.OptionalNumber = {}

---Pass this as a `defaultValue` to `:get()` (or use it as a value in `:mapSection()`) to get either a string or, if it’s missing, `nil`.
ac.INIConfig.OptionalString = {}

---Pass this as a `defaultValue` to `:get()` (or use it as a value in `:mapSection()`) to get either a list of original values or, if it’s missing, `nil`.
ac.INIConfig.OptionalList = {}

---Parse INI config from a string.
---@param data string @Serialized INI data.
---@param format ac.INIFormat? @Format to parse. Default value: `ac.INIFormat.Default`.
---@return ac.INIConfig
function ac.INIConfig.parse(data, format)
  ffi.C.lj_parse_ini(data and tostring(data) or nil, tonumber(format) or 0)
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  return ac.INIConfig(tonumber(format) or 0, ret)
end

---Load INI file, optionally with includes.
---@param filename string @INI config filename.
---@param format ac.INIFormat? @Format to parse. Default value: `ac.INIFormat.Default`.
---@param includeFolders string[]? @Optional folders to include files from (only for `ac.INIFormat.ExtendedIncludes` format). If not set, parent folder for config filename is used.
---@return ac.INIConfig
function ac.INIConfig.load(filename, format, includeFolders)
  ffi.C.lj_load_ini(filename and tostring(filename) or nil, tonumber(format) or 0, includeFolders and table.concat(includeFolders, '\n') or nil)
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  return ac.INIConfig(tonumber(format) or 0, ret, filename)
end

---Load car data INI file. Supports “data.acd” files as well. Returned files might be tweaked by
---things like custom physics virtual tyres. To get original file, use `ac.INIConfig.load()`.
---
---Returned file can’t be saved.
---@param carIndex number @0-based car index.
---@param fileName string @Car data file name, such as `'tyres.ini'`.
---@return ac.INIConfig
function ac.INIConfig.carData(carIndex, fileName)
  ffi.C.lj_load_cardata_ini(tonumber(carIndex) or 0, tostring(fileName))
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  local c = ac.INIConfig(1, ret, nil)
  c.__car = { carIndex, fileName }
  return c
end

---Load track data INI file. Can be used by track scripts which might not always  have access to those files directly.
---
---Returned file can’t be saved.
---@param fileName string @Car data file name, such as `'tyres.ini'`.
---@return ac.INIConfig
function ac.INIConfig.trackData(fileName)
  ffi.C.lj_load_trackdata_ini(tostring(fileName))
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  return ac.INIConfig(1, ret, nil)
end

---Returns config with extra online options, the ones that can be set with Content Manager.
---@return ac.INIConfig|nil @If not an online session, returns `nil`.
function ac.INIConfig.onlineExtras()
  ffi.C.lj_loadonlineextras_ini()
  local ret = __getResult__()
  if ret == nil then return nil end
  return ac.INIConfig(10, ret, nil)
end

---Returns race config (`cfg/race.ini`). Password and online GUID won’t be included.
---@return ac.INIConfig
function ac.INIConfig.raceConfig()
  ffi.C.lj_load_race_ini()
  return ac.INIConfig(10, __getResult__(), nil)
end

---Returns video config (`cfg/video.ini`).
---@return ac.INIConfig
function ac.INIConfig.videoConfig()
  ffi.C.lj_load_video_ini()
  return ac.INIConfig(10, __getResult__(), nil)
end

---Load config of a CSP module by its name.
---@param cspModuleID ac.CSPModuleID @Name of a CSP module.
---@return ac.INIConfig
function ac.INIConfig.cspModule(cspModuleID)
  if cspModuleID == nil then error('Module ID is required', 2) end
  ffi.C.lj_loadconfig_ini(tostring(cspModuleID)..'.ini')
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  return ac.INIConfig(ac.INIFormat.Extended, ret, ac.getFolder(ac.FolderID.ExtCfgUser)..'/'..cspModuleID..'.ini')
end

---Load config of the current Lua script (“settings.ini” in script directory and settings overriden by user, meant to be customizable with Content Manager). Can’t
---be changed by script directly.
---@return ac.INIConfig
function ac.INIConfig.scriptSettings()
  ffi.C.lj_loadscriptconfig_ini()
  local ret = __getResult__()
  if ret == nil then error('Failed to parse data', 2) end
  return ac.INIConfig(ac.INIFormat.Extended, ret, nil)
end

local function _indv(defaultValue)
  if defaultValue == ac.INIConfig.OptionalList
    or defaultValue == ac.INIConfig.OptionalString 
    or defaultValue == ac.INIConfig.OptionalNumber
    or defaultValue == ac.INIConfig.OptionalBoolean then return nil end
  return defaultValue
end

function ac.INIConfig:get(section, key, defaultValue, offset)
  offset = offset or 1
  if offset < 1 then return _indv(defaultValue) end
  local s = self.sections[section]
  local v = s and s[key]
  if not v or offset > #v then return _indv(defaultValue) end
  if defaultValue == nil or type(defaultValue) == 'table' then
    if defaultValue == ac.INIConfig.OptionalString then return v[offset] end
    if defaultValue == ac.INIConfig.OptionalNumber then return tonumber(v[offset]) end
    if defaultValue == ac.INIConfig.OptionalBoolean then return v[offset] ~= '0' end
    return offset > 1 and table.slice(v, offset) or v
  end
  if type(defaultValue) == 'string' then return v[offset] end
  if type(defaultValue) == 'number' then return tonumber(v[offset]) or defaultValue end
  if type(defaultValue) == 'boolean' then return v[offset] ~= '0' end
  if vec2.isvec2(defaultValue) then return vec2(tonumber(v[offset]) or 0, tonumber(v[offset + 1]) or 0) end
  if vec3.isvec3(defaultValue) then return vec3(tonumber(v[offset]) or 0, tonumber(v[offset + 1]) or 0, tonumber(v[offset + 2]) or 0) end
  if rgb.isrgb(defaultValue) then return rgb(tonumber(v[offset]) or 0, tonumber(v[offset + 1]) or 0, tonumber(v[offset + 2]) or 0) end
  if vec4.isvec4(defaultValue) then return vec4(tonumber(v[offset]) or 0, tonumber(v[offset + 1]) or 0, tonumber(v[offset + 2]) or 0, tonumber(v[offset + 3]) or 0) end
  if rgbm.isrgbm(defaultValue) then return rgbm(tonumber(v[offset]) or 0, tonumber(v[offset + 1]) or 0, tonumber(v[offset + 2]) or 0, tonumber(v[offset + 3]) or 0) end
  error('Unknown type', 2)
end

function ac.INIConfig:tryGetLut(section, key)
  local data = self:get(section, key, '')
  if not data then return nil end
  data = data:trim()
  if data == '' then return nil end
  if data:startsWith('(') and data:endsWith(')') then
    return ac.DataLUT11.parse(data)
  end
  if self.__car then
    return ac.DataLUT11.carData(self.__car[1], data)
  end
  if self.filename then
    return ac.DataLUT11.load(self.filename..'/../'..data)
  end
  return nil
end

function ac.INIConfig:mapSection(section, defaults)
  return table.map(defaults, function (v, k, s) return s:get(section, k, v), k end, self)
end

function ac.INIConfig:mapConfig(defaults)
  return table.map(defaults, function (v, k, s) return s:mapSection(k, v), k end, self)
end

function ac.INIConfig:set(section, key, value)
  local s = self.sections[section]
  if s == nil then
    s = {}
    self.sections[section] = s
  end
  if value == nil then s[key] = value
  elseif type(value) == 'table' then 
    if value == ac.INIConfig.OptionalList or value == ac.INIConfig.OptionalString 
        or value == ac.INIConfig.OptionalNumber or value == ac.INIConfig.OptionalBoolean then
      s[key] = nil
    else
      s[key] = value
    end
  elseif type(value) == 'string' then s[key] = { value }
  elseif type(value) == 'number' then s[key] = { tostring(value) }
  elseif type(value) == 'boolean' then s[key] = { value and '1' or '0' }
  elseif vec2.isvec2(value) then s[key] = { tostring(value.x), tostring(value.y) }
  elseif vec3.isvec3(value) then s[key] = { tostring(value.x), tostring(value.y), tostring(value.z) }
  elseif rgb.isrgb(value) then s[key] = { tostring(value.r), tostring(value.g), tostring(value.b) }
  elseif vec4.isvec4(value) then s[key] = { tostring(value.x), tostring(value.y), tostring(value.z), tostring(value.w) }
  elseif rgbm.isrgbm(value) then s[key] = { tostring(value.r), tostring(value.g), tostring(value.b), tostring(value.mult) } 
  else error('Unknown type', 2) end
  return self
end

local function callbackIterateSort(a, b)
  return a:alphanumCompare(b) < 0
end

function ac.INIConfig:iterate(prefix, noPostfixForFirst)
  if self.format >= 10 then
    local ret = {}
    local key
    local pattern = '^'..prefix..'_%d.*$'
    while true do
      key = next(self.sections, key)
      if not key then break end
      if not key:endsWith('_') and key:find(pattern) then ret[#ret + 1] = key end
    end
    table.sort(ret, callbackIterateSort)
    return ipairs(ret)
  else
    local i = 0
    return function ()
      local k = i == 0 and noPostfixForFirst and prefix or prefix..'_'..tostring(i)
      i = i + 1
      if self.sections[k] then return i, k end
    end
  end
end

function ac.INIConfig:iterateValues(section, prefix, digitsOnly)
  local data = self.sections[section]
  if not data then return function () end end

  local ret = {}
  local key
  local pattern = '^'..prefix..(digitsOnly and '_%d+$' or '_%d.*$')
  while true do
    key = next(data, key)
    if not key then break end
    if not key:endsWith('_') and key:find(pattern) then ret[#ret + 1] = key end
  end
  table.sort(ret, callbackIterateSort)
  return ipairs(ret)
end

function ac.INIConfig:setAndSave(section, key, value)
  if not self.filename then error('Filename is not set', 2) end
  local old = self:get(section, key, ac.INIConfig.OptionalString)
  self:set(section, key, value)
  local new = self:get(section, key, ac.INIConfig.OptionalString)
  if new == old then return false end
  ffi.C.lj_write_value_ini(self.filename, self.format, section, key, new)
  return true
end

local _iemap = { ['\''] = '\\\'', ['\\'] = '\\\\', ['\n'] = '\\n', ['\t'] = '\\t' }

local function _iechar(c)
  return _iemap[c] or c
end

function ac.INIConfig:__tostring()
  local r, i = {}, 1
  local q = self.format >= 10
  for k, v in pairs(self.sections) do
    r[i], i = '[', i + 1
    r[i], i = k, i + 1
    r[i], i = ']\n', i + 1
    for k0, v0 in pairs(v) do
      r[i], i = k0, i + 1
      r[i], i = '=', i + 1
      for j = 1, #v0 do
        if j > 1 then r[i], i = ',', i + 1 end
        if q and string.match(v0[j], '[\\\'\",\n\t=$@]') then
          r[i], i = '\'', i + 1
          r[i], i = string.gsub(v0[j], '[\\\'\n\t]', _iechar), i + 1
          r[i], i = '\'', i + 1
        else
          r[i], i = v0[j], i + 1
        end
      end
      r[i], i = '\n', i + 1
    end
    r[i], i = '\n', i + 1
  end
  return table.concat(r)
end

---Serializes data in INI format using format specified on INIConfig creation. You can also use `tostring()` function.
---@return string
function ac.INIConfig:serialize()
  return tostring(self)
end

---Saves contents to a file in INI form.
---@param filename string? @Filename. If filename is not set, saves file with the same name as it was loaded. Updates `filename` field.
---@return ac.INIConfig @Returns itself for chaining several methods together.
function ac.INIConfig:save(filename)
  self.filename = filename or self.filename
  if not self.filename then error('Filename is not set', 2) end
  io.save(self.filename, tostring(self))
  return self
end
