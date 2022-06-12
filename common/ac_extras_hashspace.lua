-- Helper for more efficient collision checks in 2D space (using 3D coordinates)

__source 'lua/api_extras_hashspace.cpp'

ffi.cdef [[ 
typedef struct {
  int* _iterate_cur;
  int* _iterate_end;
} hashspace;
]]

---@class ac.HashSpaceItem
local HashSpaceItem = class('HashSpaceItem')
function HashSpaceItem.allocate(h, id)
  return { _h = h, _id = id }
end
---Returns ID associated with an item.
---@return integer
function HashSpaceItem:id()
  return self._id
end
---Moves an item to a position.
---@param pos vec3
function HashSpaceItem:update(pos)
  if self._id < 0 then error('Already disposed', 2) end
  ffi.C.lj_hashspace_update(self._h, self._id, __util.ensure_vec3(pos))
end
---Removes item from its space.
function HashSpaceItem:dispose()
  if self._id ~= -1 then
    ffi.C.lj_hashspace_delete(self._h, self._id)
    self._id = -1
  end
end

---@param cellSize number @Should be about twice as large as your largest entity.
---@return ac.HashSpace
function ac.HashSpace(cellSize) return ffi.gc(ffi.C.lj_hashspace_new(tonumber(cellSize) or 10), ffi.C.lj_hashspace_gc) end

---Simple structure meant to speed up collision detection by arranging items in a grid using hashmap. Cells are arranged horizontally.
---@class ac.HashSpace
---@explicit-constructor ac.HashSpace
ffi.metatype('hashspace', { __index = {
  ---Iterates items around given position.
  ---@generic T
  ---@param pos vec3
  ---@param callback fun(id: integer, callbackData: T)
  ---@param callbackData T?
  iterate = function (s, pos, callback, callbackData)
    ffi.C.lj_hashspace_iteratebegin(s, __util.ensure_vec3(pos))
    while s._iterate_cur ~= s._iterate_end do
      callback(s._iterate_cur[0], callbackData)
      s._iterate_cur = s._iterate_cur + 1
    end
  end,
  ---Checks if there are any items around given position.
  ---@param pos vec3
  ---@return boolean
  anyAround = function (s, pos)
    ffi.C.lj_hashspace_iteratebegin(s, __util.ensure_vec3(pos))
    return s._iterate_cur ~= s._iterate_end
  end,
  ---Count amount of items around given position.
  ---@param pos vec3
  ---@return integer
  count = function (s, pos)
    ffi.C.lj_hashspace_iteratebegin(s, __util.ensure_vec3(pos))
    return s._iterate_end - s._iterate_cur
  end,
  ---Returns raw pointers for given position for manual iteration. Be careful!
  ---@param pos vec3
  ---@return any, any
  rawPointers = function (s, pos)
    ffi.C.lj_hashspace_iteratebegin(s, __util.ensure_vec3(pos))
    return s._iterate_cur, s._iterate_end
  end,
  ---Adds a new dynamic item to the grid. Each item gets a new ID.
  ---@return ac.HashSpaceItem
  add = function (s) return HashSpaceItem(s, ffi.C.lj_hashspace_add(s)) end,
  ---Adds a fixed item to the grid, with predetermined ID. Avoid mixing dynamic and fixed items in the same grid.
  ---@param id integer
  ---@param pos vec3
  addFixed = function (s, id, pos) 
    if not vec3.isvec3(pos) then error('Position should be of a vec3 type', 2) end
    ffi.C.lj_hashspace_addfixed(s, tonumber(id) or 0, __util.ensure_vec3(pos)) 
  end
} })

