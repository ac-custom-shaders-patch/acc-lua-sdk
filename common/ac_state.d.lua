---Returns reference to a structure with various information about the state of a car. Very cheap to use.
---This is a new version with shorter name and 0-based indexing (to match other API functions).
---
---Updates once per graphics frame. You can use it in physics scripts to access things such as tyre radius, but
---for anything live there please look for specialized physics-rate updating values.
---
---Note: index starts with 0. Make sure to check result for `nil` if you’re accessing a car that might not be there. First car
---with index 0 is always there.
---@param index integer @0-based index.
---@return ac.StateCar?
function ac.getCar(index) end

---Returns Nth closest to camera car (pass 0 to get an ID of the nearest car). Inactive cars don’t count, so the number of cars
---here might be smaller than total number of cars in the race.
---@param index integer @0-based index.
---@return ac.StateCar?
function ac.getCar.ordered(index) end

---Returns Nth car in the race leaderboard (uses lap times in practice and qualify sessions). Pass 0 to get the top one.
---@param index integer @0-based index.
---@return ac.StateCar?
function ac.getCar.leaderboard(index) end

---Returns Nth car in server entry list. Pass 0 to get the first one. In offline races returns `nil`.
---@param index integer @0-based index.
---@return ac.StateCar?
function ac.getCar.serverSlot(index) end

---Iterates over all the cars from one with 0th index to the last one. Use in a for-loop. To get a Nth car, use `ac.getCar()`.
---
---Example:
---```
---for i, c in ac.iterateCars() do
---  ac.debug(i, car.position)
---end
---```
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (1-based index and car state)
function ac.iterateCars() end

---Iterates over active cars (excluding disconnected ones online) from nearest to furthest. Use in a for-loop. To get a Nth car, use `ac.getCar.ordered()`.
---
---Example:
---```
---for i, c in ac.iterateCars.ordered() do
---  ac.debug(i, car.position)
---end
---```
---@param inverse boolean? @Set to `true` to iterate in inverse order (available since 0.2.5).
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (1-based index and car state)
function ac.iterateCars.ordered(inverse) end

---Iterates over cars from first to last in the race leaderboard (uses lap times in practice and qualify sessions). Use in a for-loop. To get a Nth car, use `ac.getCar.leaderboard()`.
---
---Example:
---```
---for i, c in ac.iterateCars.leaderboard() do
---  ac.debug(i, car.position)
---end
---```
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (1-based index and car state)
function ac.iterateCars.leaderboard() end

---Iterates over cars based on their `sessionID` (index of a session slot). Use in a for-loop. To get a Nth car, use `ac.getCar.serverSlot()`. In offline races
---returns an empty iterator.
---
---Example:
---```
---for i, c in ac.iterateCars.leaderboard() do
---  ac.debug(i, car.position)
---end
---```
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (1-based index and car state)
function ac.iterateCars.serverSlots() end
