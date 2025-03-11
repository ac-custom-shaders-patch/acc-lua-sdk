__source 'lua/api_extras_numlut.cpp'
require './common/internal_import'

ffi.cdef [[ 
typedef struct {
  uint columns;
  float* calculated;
} numlut;
]]

---Meant to quickly interpolate between tables of values, some of them could be colors set in HSV. Example:
---```
---local lut = ac.Lut([[
--- -100 |  0.00,   350,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
---  -90 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
---  -20 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
---]], { 2 })
---assert(lut:calculate(-95)[1] == 0.5)
---```
---@class ac.Lut
---@explicit-contructor ac.Lut
ffi.metatype('numlut', { __index = {
  ---Interpolate for a given input, return a newly created table. Note: consider using `:calculateTo()` instead to avoid re-creating tables, it would work much more efficiently.
  ---@param input number
  ---@return number[]
  calculate = function (s, input)
    ffi.C.lj_numlut_calculate(s, input)
    local ret = {}
    for i = 1, s.columns do
      ret[i] = s.calculated[i - 1]
    end
    return ret
  end,
  ---Interpolate for a given input, write result to a given table.
  ---@param output number[]
  ---@param input number
  ---@return number[] @Same table as was provided in arguments.
  calculateTo = function (s, output, input)
    ffi.C.lj_numlut_calculate(s, input)
    for i = 1, s.columns do
      output[i] = s.calculated[i - 1]
    end
    return output
  end
} })

__definitions()

return function (data, hsvColumns)  
  local hsvRowsData = ''
  for i = 1, #hsvColumns do
    hsvRowsData = i > 1 and (hsvRowsData .. ',' .. (hsvColumns[i] - 1)) or (hsvRowsData .. (hsvColumns[i] - 1))
  end
  local created = ffi.C.lj_numlut_new(data and tostring(data) or "", hsvRowsData)
  return ffi.gc(created, ffi.C.lj_numlut_gc)
end