__source 'lua/api_dualshock.cpp'
__states 'lua/api_dualshock.cpp'

local _dhlv, _dhrn

---Return table with gamepad indices for keys and 0-based indices of associated cars for values.
---@return table<integer, integer>
function ac.getDualShockControllers()
  if not _dhrn then _dhrn = refnumber(-1) end
  ffi.C.lj_getDualShockControllers_inner(_dhrn)
  _dhlv = __getResult__() or _dhlv
  return _dhlv or error('Failed to get data', 2)
end

