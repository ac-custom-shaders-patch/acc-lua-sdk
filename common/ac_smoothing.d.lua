

---Call it once every frame at the beginning, it would affect all instances of `smoothing`.
---@param dt number @Time passed since last frame, in seconds.
function smoothing.setDT(dt) end

---Strange thing which is only kept for backwards compatibility. Holds a value, numerical or a vector, and
---updates it every frame slowly moving it towards target value. For new projects, I would recommend to use
---something else.
---
---It doesn’t even use lag parameter, but instead some strange “smooth” thing…
---@class smoothing
---@field val number|vec2|vec3|vec4
---@field lastValue number|vec2|vec3|vec4
---@field smooth number
---@constructor fun(initialValue: number|vec2|vec3|vec4, smoothingIntensity: number "Default value: 100."): smoothing

---Updates value, moving it closer to `newValue`.
---@param newValue number|vec2|vec3|vec4 @Target value to move to.
function smoothing:update(newValue) end

---Updates value, moving it closer to `newValue`, but only if `newValue` is different from the one used in
---`:updateIfNew()` last time. And for vectors it compares not by value, but by reference. Makes me wonder what was I
---thinking about.
---@param newValue number|vec2|vec3|vec4 @Target value to move to.
function smoothing:updateIfNew(newValue) end
