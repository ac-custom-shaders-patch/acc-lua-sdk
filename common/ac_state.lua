__source 'lua/api_state_provider.cpp'
__states 'lua/api_state_provider.cpp'

do
  local function _ptri(v, i)
    if v[i] ~= nil then return i + 1, v[i] end
  end

  ac.iterateCars = setmetatable({
    ordered = function ()
      return _ptri, ffi.C.lj_getCars_inner(true), 0
    end,
  }, {
    __call = function(_)
      return _ptri, ffi.C.lj_getCars_inner(false), 0
    end
  })
end