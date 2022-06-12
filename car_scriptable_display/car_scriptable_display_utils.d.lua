---@class display.InteractiveMeshFactory
local _interactiveMeshFactory = {}

---Call function and check its return value. If it’s `true`, event is happening right now. No need to cache
---its output somewhere local, it shouldn’t be that expensive (all raycasting is done when needed and no more than
---once per frame).
---@alias display.EventListener fun(): boolean

---Create new listener which would response to mesh (or area of a mesh) being clicked (proper VR integration is coming later). If you only need to
---listen to an area of a mesh, you can limit it by specifying a certain UV region or an area close to some point in car space (or both).
---@param texStart vec2|nil @UV coordinate of the top left corner of UV region. Optional. Goes from 0 to 1 unless you specified resolution when creating `display.InteractiveMeshFactory`, otherwise it would use coordinates in pixels.
---@param texSize vec2|nil @UV region size. Optional. Goes from 0 to 1 unless you specified resolution when creating `display.InteractiveMeshFactory`, otherwise it would use coordinates in pixels.
---@param inCarPos vec3|nil @Target position relative to car. Optional. If it and `inCarRadius` are set, only clicks closer to `inCarPos` than `inCarRadius` are registered.
---@param inCarRadius number|nil @Threshold radius in meters. Optional. If it and `inCarPos` are set, only clicks closer to `inCarPos` than `inCarRadius` are registered.
---@param inCarLocalPos boolean|nil @If set to true, local mesh coordinates are checked. Note: if mesh is scaled, distance would have to be scaled too.
---@param repeatIntervalSeconds number|nil @If set, clicks would repeat after given time has passed. Helps to create repeating buttons (ones that you can hold for a value to increase more and more, for example).
---@overload fun(inCarPos: vec3, inCarRadius: number, repeatIntervalSeconds?: number): display.EventListener
---@overload fun(inCarPos: vec3, inCarRadius: number, inCarLocalPos: boolean, repeatIntervalSeconds?: number): display.EventListener
---@overload fun(texStart: vec2, texSize: vec2, inCarPos: vec3, inCarRadius: number, repeatIntervalSeconds?: number): display.EventListener
---@overload fun(texStart: vec2, texSize: vec2, repeatIntervalSeconds?: number): display.EventListener
---@return display.EventListener
function _interactiveMeshFactory.clicked(texStart, texSize, inCarPos, inCarRadius, inCarLocalPos, repeatIntervalSeconds) end

---Create new listener which would response to mesh (or area of a mesh) being pressed by a mouse (proper VR integration is coming later). If you only need to
---listen to an area of a mesh, you can limit it by specifying a certain UV region or an area close to some point in car space (or both).
---
---For holding button down (to press a couple of them at once, for example) use right or middle mouse buttons.
---@param texStart vec2|nil @UV coordinate of the top left corner of UV region. Optional. Goes from 0 to 1 unless you specified resolution when creating `display.InteractiveMeshFactory`, otherwise it would use coordinates in pixels.
---@param texSize vec2|nil @UV region size. Optional. Goes from 0 to 1 unless you specified resolution when creating `display.InteractiveMeshFactory`, otherwise it would use coordinates in pixels.
---@param inCarPos vec3|nil @Target position relative to car. Optional. If it and `inCarRadius` are set, only mouse presses closer to `inCarPos` than `inCarRadius` are registered.
---@param inCarRadius number|nil @Threshold radius in meters. Optional. If it and `inCarPos` are set, only mouse presses closer to `inCarPos` than `inCarRadius` are registered.
---@param inCarLocalPos boolean|nil @If set to true, local mesh coordinates are checked. Note: if mesh is scaled, distance would have to be scaled too.
---@overload fun(inCarPos: vec3, inCarRadius: number): display.EventListener
---@overload fun(texStart: vec2, texSize: vec2): display.EventListener
---@return display.EventListener
function _interactiveMeshFactory.pressed(texStart, texSize, inCarPos, inCarRadius, inCarLocalPos) end