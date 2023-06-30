---Iterates over all the cars from one with 0th index to the last one. Use in a for-loop.
---
---Example:
---```
---for i, c in ac.iterateCars() do
---  ac.debug(i, car.position)
---end
---```
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (0-based car index and car state)
function ac.iterateCars() end

---Iterates over active cars (excluding disconnected ones online) from nearest to furthest. Use in a for-loop.
---
---Example:
---```
---for i, c in ac.iterateCars.ordered() do
---  ac.debug(i, car.position)
---end
---```
---@return fun(): integer, ac.StateCar @Iterator to be used in a loop (0-based car index and car state)
function ac.iterateCars.ordered() end
