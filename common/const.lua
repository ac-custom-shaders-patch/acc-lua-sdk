---Does nothing, but with preprocessing optimizations inlines value as constant.
---@generic T
---@param value T
---@return T
function const(value)
  return value
end
