__source 'lua/api_track_conditions.cpp'

ffi.cdef [[ 
typedef struct {
  void* data__;
} trackcondition;
]]

---Creates a wrapper to access track condition. If you want to get the value often, consider caching and reusing the wrapper.
---@param expression string @Expression similar to ones config have as CONDITION=… value.
---@param offset number? @Condition offset. Default value: 0.
---@param defaultValue number? @Default value in case referenced condition is missing or parsing failed. Default value: 0.
---@return ac.TrackCondition
function ac.TrackCondition(expression, offset, defaultValue)
end

ac.TrackCondition = setmetatable({
  count = function ()
    return ffi.C.lj_trackcondition_count()
  end,
  name = function (i)
    return __util.strrefp(ffi.C.lj_trackcondition_at_name(tonumber(i) or -1))
  end,
  input = function (i)
    return __util.strrefp(ffi.C.lj_trackcondition_at_input(tonumber(i) or -1))
  end,
  get = function (i, offset)
    return ffi.C.lj_trackcondition_at_value(tonumber(i) or -1, tonumber(offset) or 0)
  end,
  getColor = function (i, offset)
    return ffi.C.lj_trackcondition_at_value3(tonumber(i) or -1, tonumber(offset) or 0)
  end,
}, {
  __call = function(_, expression, offset, defaultValue)
    if type(expression) == 'number' then
      return ffi.gc(ffi.C.lj_trackcondition_new_id(expression, tonumber(offset) or 0, tonumber(defaultValue) or 0), ffi.C.lj_trackcondition_gc)
    end
    return ffi.gc(ffi.C.lj_trackcondition_new(__util.str(expression), tonumber(offset) or 0, tonumber(defaultValue) or 0), ffi.C.lj_trackcondition_gc)
  end
})

---Track condition evaluator. Given expression, which might refer to some existing condition, condition input or a complex expression of those,
---computes the resulting value.
---@class ac.TrackCondition
ffi.metatype('trackcondition', { __index = {

  ---@param offset number? @Optional offset (in case track condition has a variance).
  ---@return number
  get = function (s, offset) return ffi.C.lj_trackcondition_get(s, tonumber(offset) or 0) end,

  ---@param offset number? @Optional offset (in case track condition has a variance).
  ---@return rgb
  getColor = function (s, offset) return ffi.C.lj_trackcondition_getcolor(s, tonumber(offset) or 0) end,

  ---Returns `true` if there is a condition with value changing live.
  ---@return boolean
  isDynamic = function (s) return ffi.C.lj_trackcondition_isdynamic(s) end,

  ---Returns condition input, if any.
  ---@return string?
  input = function (s) return __util.strrefp(ffi.C.lj_trackcondition_input(s)) end,

  ---Returns condition name, if any.
  ---@return string?
  name = function (s) return __util.strrefp(ffi.C.lj_trackcondition_name(s)) end,

} })
