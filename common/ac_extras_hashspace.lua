-- Helper for more efficient collision checks in 2D space (using 3D coordinates)

---@param cellSize number @Should be about twice as large as your largest entity.
---@return ac.HashSpace
function ac.HashSpace(cellSize) return __util.lazy('lib_hashspace')(cellSize) end
