---A wrapper for data parsed from an INI files, supports different INI formats. Parsing is done on
---CSP side, rest is on CSP side. Use `:get()` and `:set()` methods to operate values.
---@class ac.INIConfig
---@field sections table<string, table<string, string[]>> @Sections storing actual data.
---@field format ac.INIFormat? @Format used when creating a config. Default value: `ac.INIFormat.Default`.
---@field filename string? @Optional filename for configs loaded from a file.
---@constructor fun(format: ac.INIFormat, sections: table): ac.INIConfig

---Get value from parsed INI file. Note: getting vector values creates them anew, so if you’re going to use a value often, consider
---caching it locally.
---@generic T
---@param section string @Section name.
---@param key string @Value key.
---@param defaultValue T @Defines type of value to return, is returned if value is missing. If not set, list of strings is returned.
---@param offset integer? @Optional 1-based offset for data parsed in CSP format (in case value contains several items). Default value: 1.
---@return T
function ac.INIConfig:get(section, key, defaultValue, offset) end

---Attempts to load a 1D-to-1D LUT from an INI file, supports both inline “(|X=Y|…|)” LUTs and separate files next to configs (only
---for configs loaded by filename or from car data)
---@return ac.DataLUT11? @Returns `nil` if there is no such key or no such file.
function ac.INIConfig:tryGetLut(section, key) end

---Iterates over sections of INI file with a certain prefix. Order matches order of CSP parsing such data.
---
---Example:
---```
---for index, section in iniConfig:iterate('LIGHT') do
---  print('Color: '..iniConfig:get(section, 'COLOR', 'red'))
---end
---```
---@param prefix string @Prefix for section names.
---@param noPostfixForFirst boolean? @Only for default INI format. If set to `true`, first section would not have “_0” postfix.
---@return fun(): integer?, string? @If you need a list instead of an iterator, use `table.build()`.
function ac.INIConfig:iterate(prefix, noPostfixForFirst) end

---Iterates over values of INI section with a certain prefix. Order matches order of CSP parsing such data.
---
---Example:
---```
---for index, key in iniConfig:iterateValues('LIGHT_0', 'POSITION', true) do
---  print('Position: '..tostring(iniConfig:get('LIGHT_0', key, vec3())))
---end
---```
---@param prefix string @Prefix for section names.
---@param digitsOnly boolean? @If set to `true`, would only collect keys consisting of a prefix and a number (useful for configs with extra properties).
---@return fun(): integer?, string? @If you need a list instead of an iterator, use `table.build()`.
function ac.INIConfig:iterateValues(section, prefix, digitsOnly) end

---Takes table with default values and returns a table with values filled from config.
---@generic T
---@param section string @Section name.
---@param defaults T @Table with keys and default values. Keys are the same as INI keys.
---@return T
function ac.INIConfig:mapSection(section, defaults) end

---Takes table with default values and returns a table with values filled from config.
---@generic T
---@param defaults T @Table with section names and sub-tables with keys and default values. Keys are the same as INI keys.
---@return T
function ac.INIConfig:mapConfig(defaults) end

---Set an INI value. Pass `nil` as value to remove it.
---@param section string
---@param key string
---@param value string|string[]|number|boolean|nil|vec2|vec3|vec4|rgb|rgbm
---@return ac.INIConfig @Returns itself for chaining several methods together.
function ac.INIConfig:set(section, key, value) end

---Set an INI value and save file immediattely using special old Windows function to edit a single INI value. Compatible only with default
---INI format. Doesn’t provide major peformance improvements, but might be useful if you prefer to keep original formatting as much as possible
---when editing a single value only.
---@param section string
---@param key string
---@param value string|string[]|number|boolean|nil|vec2|vec3|vec4|rgb|rgbm
---@return boolean @Returns `true` if new value is different and config was saved.
function ac.INIConfig:setAndSave(section, key, value) end

---Serializes data in INI format using format specified on INIConfig creation. You can also use `tostring()` function.
---@return string
function ac.INIConfig:serialize() end

---Saves contents to a file in INI form.
---@param filename string? @Filename. If filename is not set, saves file with the same name as it was loaded. Updates `filename` field.
---@return ac.INIConfig @Returns itself for chaining several methods together.
function ac.INIConfig:save(filename) end
