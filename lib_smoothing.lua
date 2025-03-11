local _dt = 0.0167
local mt = {
  __tostring = function(v)
    return string.format('(%s, s=%f)', v.val, v.smooth)
  end,
  __index = {
    update = function(v, x)
      v.val = math.applyLag(v.val, x, 1 - 1 / v.smooth, _dt)
    end,
    updateIfNew = function(v, x)
      if x ~= v.lastValue then
        v.val = math.applyLag(v.val, x, 1 - 1 / v.smooth, _dt)
        v.lastValue = x
      end
    end
  }
}

__definitions()

return {
  c = function (v, s)
    return setmetatable({ val = v or 0, lastValue = v or 0, smooth = s or 100 }, mt)
  end,
  s = function (dt)
    _dt = math.applyLag(_dt, dt, 0.9, _dt)
  end
}