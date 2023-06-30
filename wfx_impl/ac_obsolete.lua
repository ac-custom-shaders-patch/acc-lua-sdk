---@deprecated
ac.SHADOWS_ON = 1

---@deprecated
ac.SHADOWS_OFF = 0

---@deprecated
function ac.setSkySunSize(v) end

---@deprecated
function ac.setSunAngle(v) end

---@deprecated
function ac.setCustomSunDirection(v) end

---@deprecated
function ac.setReflectionsLuminanceBoost(v) end

---@deprecated
function ac.setSkyExtraGradient(id, gradient)
  if id < 0 or id >= 32 then error('Gradient ID should be within 0-31 range', 2) end
  ac.skyExtraGradients:set(id + 1, gradient)
end

---@deprecated
ac.addSkyExtraGradients = ac.addSkyExtraGradient
