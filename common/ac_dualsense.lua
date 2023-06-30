__source 'lua/api_dualsense.cpp'
__states 'lua/api_dualsense.cpp'

local _dslv, _dsrn

---Return table with gamepad indices for keys and 0-based indices of associated cars for values.
---@return table<integer, integer>
function ac.getDualSenseControllers()
  if not _dsrn then _dsrn = refnumber(-1) end
  ffi.C.lj_getDualSenseControllers_inner(_dsrn)
  _dslv = __util.result() or _dslv
  return _dslv or error('Failed to get data', 2)
end

