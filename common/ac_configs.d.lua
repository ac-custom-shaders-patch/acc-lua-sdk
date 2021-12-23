---@class ac.ConfigProvider
local _ac_ConfigProvider = {}

---@param section string
---@param key string
---@param defaultValue boolean|nil
---@return boolean
function _ac_ConfigProvider.bool(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue number
---@return number
function _ac_ConfigProvider.number(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue string|nil
---@return string
function _ac_ConfigProvider.string(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue rgb|nil
---@return rgb
function _ac_ConfigProvider.rgb(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue rgbm|nil
---@return rgbm
function _ac_ConfigProvider.rgbm(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue vec2|nil
---@return vec2
function _ac_ConfigProvider.vec2(section, key, defaultValue) end
---@param section string
---@param key string
---@param defaultValue vec3|nil
---@return vec3
function _ac_ConfigProvider.vec3(section, key, defaultValue) end

---@param section string
---@param key string
---@param defaultValue vec4|nil
---@return vec4
function _ac_ConfigProvider.vec4(section, key, defaultValue) end

---Reads a value from the config of currently loaded track. To use it, you need to specify `defaultValue` value, it would be used to determine
---the type of the value you need (and would be returned if value in config is missing).
---
---Alternatively, if called without arguments, returns ac.ConfigProvider which then can be used to access
---values in a typed manner. For it, `defaultValue` is optional.
---@generic T
---@param section string @Section name in config (the one in square brackets).
---@param key string @Config key (value before “=” sign).
---@param defaultValue T @Value that’s returned as a result if value is missing. Also determines the type needed.
---@return T
---@overload fun(): ac.ConfigProvider
function ac.getTrackConfig(section, key, defaultValue) end

---Reads a value from the config of a car. To use it, you need to specify `defaultValue` value, it would be used to determine
---the type of the value you need (and would be returned if value in config is missing).
---
---Alternatively, if called with car index only, returns ac.ConfigProvider which then can be used to access
---values in a typed manner. For it, `defaultValue` is optional.
---@generic T
---@param carIndex integer @0-based car index.
---@param section string @Section name in config (the one in square brackets).
---@param key string @Config key (value before “=” sign).
---@param defaultValue T @Value that’s returned as a result if value is missing. Also determines the type needed.
---@return T
---@overload fun(carIndex: integer): ac.ConfigProvider
function ac.getCarConfig(carIndex, section, key, defaultValue) end
