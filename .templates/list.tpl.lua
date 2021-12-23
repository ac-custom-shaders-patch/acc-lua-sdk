--[[?/*]] ---@diagnostic disable: undefined-doc-name --[[*/?]]
--[[? for (const [list, item] of args){ const listType = list.replace(/\.[a-z]/, _ => _.toUpperCase()) + 'List'; out(]]
---List of active __item__. Use it to add or remove elements to the scene.
---@class __listType__ : ac.GenericList
---@single-instance
__list__ = nil

---@param index integer
---@return __item__
function __list__:get(index) end

---If item is null, element will be removed from said position, moving rest one step forward to close the gap.
---@param index integer
---@param item __item__
function __list__:set(index, item) end

---@param index integer
---@param item __item__
function __list__:insert(index, item) end

---@param item __item__
function __list__:push(item) end

---Inserts element to a first empty spot.
---@param item __item__
function __list__:pushWhereFits(item) end

---Removes an element from the list (first occurance only).
---@param item __item__
function __list__:erase(item) end

---Removes an element from a position, moves the rest one step forward to close the gap.
---@param index integer
---@return __item__ @Removed element.
function __list__:remove(index) end

---Removes the last element and returns it.
---@return __item__
function __list__:pop() end
--[[) } ?]]
