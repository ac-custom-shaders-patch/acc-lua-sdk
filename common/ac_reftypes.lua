ffi.cdef [[ 
typedef struct { bool value; } refbool;
typedef struct { float value; } refnumber;
]]

---Stores a boolean value and can be used as a reference to it.
---@class refbool
---@field value boolean @Stored value.
refbool = ffi.metatype('refbool', { __index = {
  ---@return boolean
  isrefbool = function(x) return ffi.istype('refbool', x) end,

  ---For easier use with UI controls.
  ---@param newValue boolean
  ---@return refbool
  set = function (s, newValue) s.value = newValue return s end
} })

---Stores a numerical value and can be used as a reference to it.
---@class refnumber
---@field value number @Stored value.
refnumber = ffi.metatype('refnumber', { __index = {
  ---@return boolean
  isrefnumber = function(x) return ffi.istype('refnumber', x) end,

  ---For easier use with UI controls.
  ---@param newValue number
  ---@return refnumber
  set = function (s, newValue) s.value = newValue return s end
} })

