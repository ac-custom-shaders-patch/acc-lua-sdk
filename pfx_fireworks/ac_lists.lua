ac.fireworks = __util.boundArray(ffi.typeof('firework*'), ffi.C.lj_set_fireworks)

---Adds a firework to the list of active fireworks.
---@param item ac.Firework
function ac.addFirework(item) return ac.fireworks:pushWhereFits(item) end

---Removes a firework from the list of active fireworks.
---@param item ac.Firework
function ac.removeFirework(item) return ac.fireworks:erase(item) end
