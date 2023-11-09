__source 'extensions/track_adjustments/track_scriptable_display.cpp'
__allow 'tsd'

---Finds a car at a given place in a race, for creating leaderboards. Returns nil if couldn’t find a car.
---@param place integer @Starts with 1 for first place.
---@return ac.StateCar|nil
function ac.findCarAtPlace(place)
  for i = 0, ac.getSim().carsCount - 1 do  -- getCar() needs IDs from 0 to N-1
    local car = ac.getCar(i)
    if car.racePosition == place then return car end
  end
  return nil -- couldn’t find anything
end
