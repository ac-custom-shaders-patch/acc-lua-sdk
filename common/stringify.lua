stringify = setmetatable({
  tryParse = function(v, env, fallback)
    return __util.lazy('lib_stringify').tryParse(v, env, fallback)
  end,
  parse = function (v, env)
    return __util.lazy('lib_stringify').parse(v, env)
  end,
  register = function(n, v)
    return __util.lazy('lib_stringify').register(n, v)
  end,
  locals = function ()
    local variables = {}
    local idx = 1
    while debug do
      local ln, lv = debug.getlocal(2, idx)
      if ln ~= nil then
        variables[ln] = lv
      else
        break
      end
      idx = 1 + idx
    end
    return variables
  end,
  substep = function (out, ptr, obj, lineBreak, depthLimit)
    return __util.lazy('lib_stringify').substep(out, ptr, obj, lineBreak, depthLimit)
  end,
  binary = setmetatable({
    tryParse = function (v, fallback)
      local r, p = pcall(__util.prs().unpackString, v)
      if r then return p end
      return fallback
    end,
    parse = function (v)
      return __util.prs().unpackString(v)
    end,
  }, {
    __call = function(_, data)
      return __util.prs().packString(data)
    end
  })
}, {
  __call = function(_, v, compact, depthLimit)
    return __util.lazy('lib_stringify').call(v, compact, depthLimit)
  end
})