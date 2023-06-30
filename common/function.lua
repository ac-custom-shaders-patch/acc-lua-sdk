-- Extensions for functions

do
  local _dgi = debug.getinfo

  -- (function (arg1, arg2) end):bind(value for arg1, value for arg2)
  -- this way calls should be faster than merging tables on-fly
  debug.setmetatable(function()end, {
    __index = {
        bind = function(s, ...)
          local a = {...}
          if #a == 0 then
            return s
          end
          local i = _dgi(s)
          if not i.isvararg then
            if i.nparams == 0 then return s end
            if i.nparams == 1 then return function() return s(a[1]) end end
            if i.nparams == 2 then
              if #a == 1 then return function(a0) return s(a[1], a0) end 
              else return function() return s(a[1], a[2]) end end
            end
            if i.nparams == 3 then
              if #a == 1 then return function(a0, a1) return s(a[1], a0, a1) end 
              elseif #a == 2 then return function(a0) return s(a[1], a[2], a0) end 
              else return function() return s(a[1], a[2], a[3]) end end
            end
            if i.nparams == 4 then
              if #a == 1 then return function(a0, a1, a2) return s(a[1], a0, a1, a2) end 
              elseif #a == 2 then return function(a0, a1) return s(a[1], a[2], a0, a1) end 
              elseif #a == 3 then return function(a0) return s(a[1], a[2], a[3], a0) end 
              else return function() return s(a[1], a[2], a[3], a[4]) end end
            end
          end
          if #a == 1 then return function(...) return s(a[1], ...) end end
          if #a == 2 then return function(...) return s(a[1], a[2], ...) end end
          if #a == 3 then return function(...) return s(a[1], a[2], a[3], ...) end end
          if #a == 4 then return function(...) return s(a[1], a[2], a[3], a[4], ...) end end
          if #a == 5 then return function(...) return s(a[1], a[2], a[3], a[4], a[5], ...) end end
          error('Not supported', 2)
        end,
    },
    __pow = function (s, arg)
      local i = _dgi(s)
      if i.isvararg or i.nparams > 3 then
        return function (...) return s(arg, ...) end
      elseif i.nparams == 1 then
        return function () return s(arg) end
      elseif i.nparams == 2 then
        return function (a0) return s(arg, a0) end
      elseif i.nparams == 3 then
        return function (a0, a1) return s(arg, a0, a1) end
      else
        return s
      end
    end
  })
end
