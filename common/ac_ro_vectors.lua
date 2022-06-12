--[[? for (const TYPE of ['int', 'float']){ out(]]

ffi.cdef [[ typedef struct { const __TYPE__* _begin; const __TYPE__* _end; const __TYPE__* _cap; } lua_vector___TYPE__; ]]
ffi.metatype('lua_vector___TYPE__', { 
  __len = function (v)
    return v._end - v._begin
  end,
  __tostring = function(v)
    local t, n = {'('}, 2
    for i = 0, v._end - v._begin - 1 do
      if n == 2 then
        t[n], n = v._begin[i], n + 1
      else
        t[n], t[n + 1], n = ', ', v._begin[i], n + 2
      end
    end
    t[n] = ')'
    return table.concat(t)
  end,
  __index = function(v, k)
    if type(k) ~= 'number' or k < 0 or v._begin + k >= v._end then return nil end
    return v._begin[k]
  end,
  __newindex = function() error('This list is read-only', 2) end
})

--[[) } ?]]
