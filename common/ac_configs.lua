local oldImpl = {
  bool = function(section, key, def) return ffi.C.lj_cfg_track_bool(__util.str(section), __util.str(key), def and true or false) end,
  number = function(section, key, def) return ffi.C.lj_cfg_track_decimal(__util.str(section), __util.str(key), def or 0) end,
  string = function(section, key, def) return __util.strref(ffi.C.lj_cfg_track_string(__util.str(section), __util.str(key), __util.str(def))) end,
  rgb = function(section, key, def) return ffi.C.lj_cfg_track_rgb(__util.str(section), __util.str(key), def or rgb()) end,
  rgbm = function(section, key, def) return ffi.C.lj_cfg_track_rgbm(__util.str(section), __util.str(key), def or rgbm()) end,
  vec2 = function(section, key, def) return ffi.C.lj_cfg_track_vec2(__util.str(section), __util.str(key), def or vec2()) end,
  vec3 = function(section, key, def) return ffi.C.lj_cfg_track_vec3(__util.str(section), __util.str(key), def or vec3()) end,
  vec4 = function(section, key, def) return ffi.C.lj_cfg_track_vec4(__util.str(section), __util.str(key), def or vec4()) end,
}

function ac.getTrackConfig(section, key, def)
  if section == nil then return oldImpl end
  if type(def) == 'boolean' then return ffi.C.lj_cfg_track_bool(__util.str(section), __util.str(key), def) end
  if type(def) == 'number' then return ffi.C.lj_cfg_track_decimal(__util.str(section), __util.str(key), def) end
  if type(def) == 'string' then return __util.strref(ffi.C.lj_cfg_track_string(__util.str(section), __util.str(key), def)) end
  if rgb.isrgb(def) then return ffi.C.lj_cfg_track_rgb(__util.str(section), __util.str(key), def) end
  if rgbm.isrgbm(def) then return ffi.C.lj_cfg_track_rgbm(__util.str(section), __util.str(key), def) end
  if vec2.isvec2(def) then return ffi.C.lj_cfg_track_vec2(__util.str(section), __util.str(key), def) end
  if vec3.isvec3(def) then return ffi.C.lj_cfg_track_vec3(__util.str(section), __util.str(key), def) end
  if vec4.isvec4(def) then return ffi.C.lj_cfg_track_vec4(__util.str(section), __util.str(key), def) end
  if def == nil then error('Default value is required', 2) end
  error('Unknown type: '..type(def), 2)
end

local _coimpl = {}

local function _getCarOldImpl(car)
  if _coimpl[car] == nil then
    _coimpl[car] = {
      bool = function(section, key, def) return ffi.C.lj_cfg_car_bool(car, __util.str(section), __util.str(key), def and true or false) end,
      number = function(section, key, def) return ffi.C.lj_cfg_car_decimal(car, __util.str(section), __util.str(key), def or 0) end,
      string = function(section, key, def) return __util.strref(ffi.C.lj_cfg_car_string(car, __util.str(section), __util.str(key), __util.str(def))) end,
      rgb = function(section, key, def) return ffi.C.lj_cfg_car_rgb(car, __util.str(section), __util.str(key), def or rgb()) end,
      rgbm = function(section, key, def) return ffi.C.lj_cfg_car_rgbm(car, __util.str(section), __util.str(key), def or rgbm()) end,
      vec2 = function(section, key, def) return ffi.C.lj_cfg_car_vec2(car, __util.str(section), __util.str(key), def or vec2()) end,
      vec3 = function(section, key, def) return ffi.C.lj_cfg_car_vec3(car, __util.str(section), __util.str(key), def or vec3()) end,
      vec4 = function(section, key, def) return ffi.C.lj_cfg_car_vec4(car, __util.str(section), __util.str(key), def or vec4()) end,
    }
  end
  return _coimpl[car]
end

function ac.getCarConfig(car, section, key, def)
  if type(car) ~= 'number' then error('Car ID is required to be a number', 2) end
  if section == nil then return _getCarOldImpl(car) end
  if type(def) == 'boolean' then return ffi.C.lj_cfg_car_bool(car, __util.str(section), __util.str(key), def) end
  if type(def) == 'number' then return ffi.C.lj_cfg_car_decimal(car, __util.str(section), __util.str(key), def) end
  if type(def) == 'string' then return __util.strref(ffi.C.lj_cfg_car_string(car, __util.str(section), __util.str(key), def)) end
  if rgb.isrgb(def) then return ffi.C.lj_cfg_car_rgb(car, __util.str(section), __util.str(key), def) end
  if rgbm.isrgbm(def) then return ffi.C.lj_cfg_car_rgbm(car, __util.str(section), __util.str(key), def) end
  if vec2.isvec2(def) then return ffi.C.lj_cfg_car_vec2(car, __util.str(section), __util.str(key), def) end
  if vec3.isvec3(def) then return ffi.C.lj_cfg_car_vec3(car, __util.str(section), __util.str(key), def) end
  if vec4.isvec4(def) then return ffi.C.lj_cfg_car_vec4(car, __util.str(section), __util.str(key), def) end
  if def == nil then error('Default value is required', 2) end
  error('Unknown type: '..type(def), 2)
end
