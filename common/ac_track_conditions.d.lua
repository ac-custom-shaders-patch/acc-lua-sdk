---Creates a wrapper to access track condition. If you want to get the value often, consider caching and reusing the wrapper.
---@param expression string @Expression similar to ones config have as CONDITION=… value.
---@param offset number? @Condition offset. Default value: 0.
---@param defaultValue number? @Default value in case referenced condition is missing or parsing failed. Default value: 0.
---@return ac.TrackCondition
function ac.TrackCondition(expression, offset, defaultValue) end

---Returns number of conditions defined on the current track.
---@return integer
function ac.TrackCondition.count() end

---Returns name of a condition with certain index.
---@param index integer @0-based condition index.
---@return string? @Returns `nil` if there is no such condition.
function ac.TrackCondition.name(index) end

---Returns input of a condition with certain index.
---@param index integer @0-based condition index.
---@return string? @Returns `nil` if there is no such condition.
function ac.TrackCondition.input(index) end

---Returns value of a condition with certain index.
---@param index integer @0-based condition index.
---@param offset number? @Optional offset for conditions with variance.
---@return number @Returns `0` if there is no such condition.
function ac.TrackCondition.get(index, offset) end

---Returns RGB value of a condition with certain index.
---@param index integer @0-based condition index.
---@param offset number? @Optional offset for conditions with variance.
---@return rgb @Returns `rgb()` if there is no such condition.
function ac.TrackCondition.getColor(index, offset) end

