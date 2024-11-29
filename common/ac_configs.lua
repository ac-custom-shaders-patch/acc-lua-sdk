local _coimpl = {}

local function _cfgProvider(car)
  if _coimpl[car] == nil then
    _coimpl[car] = {
      bool = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), def and true or false) end,
      number = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), tonumber(def) or 0) end,
      string = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.str(def)) end,
      rgb = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.ensure_rgb_nil(def) or rgb()) end,
      rgbm = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.ensure_rgbm_nil(def) or rgbm()) end,
      vec2 = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.ensure_vec2_nil(def) or vec2()) end,
      vec3 = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.ensure_vec3_nil(def) or vec3()) end,
      vec4 = function(section, key, def) return __util.native('cfg', car, __util.str(section), __util.str(key), __util.ensure_vec4_nil(def) or vec4()) end,
    }
  end
  return _coimpl[car]
end

function ac.getTrackConfig(section, key, def)
  if section == nil then return _cfgProvider(65536) end
  return __util.native('cfg', 65536, section, key, def)
end

function ac.getCarConfig(car, section, key, def)
  if type(car) ~= 'number' or car < 0 then error('Car ID is required to be a number', 2) end
  if section == nil then return _cfgProvider(car) end
  return __util.native('cfg', car, section, key, def)
end
