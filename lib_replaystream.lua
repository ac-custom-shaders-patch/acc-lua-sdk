__source 'lua/api_replay_extension.cpp'

local _rpsActive = {}
ffi.cdef [[ 
typedef struct {
  void* _frame;
} replayextension;
]]

local function __si_replayMixing(reordered)
  local mixing = {}
  if reordered then
    local offset = 0

    local function procItem(v)
      local u = 1
      if v.array then
        for i = 1, #v.array do
          u = u * v.array[i]
        end
      end
      if v.struct then
        for _ = 1, u do
          for _, c in ipairs(v.struct) do
            procItem(c)
          end
        end
        return
      elseif v.replayType then
        for _ = 1, u do
          if v.replayType > 99 then
            local c = math.floor(v.replayType / 100)
            for _ = 1, c do
              mixing[#mixing + 1] = string.format('%d:%d', offset, v.replayType % 100)
              offset = offset + v.packingSize / c
            end
          else
            mixing[#mixing + 1] = string.format('%d:%d', offset, v.replayType)
            offset = offset + v.packingSize
          end
        end
      else
        offset = offset + v.realSize
      end
    end

    for _, v in ipairs(reordered) do
      procItem(v)
    end
  end
  return table.concat(mixing, '\n')
end

---Create a new stream for recording data to replays. Write data in returned structure if not in replay mode, read data if in replay mode (use `sim.isReplayActive` to check if you need to write or read the data).
---Few important points:
--- - Each frame should not exceed 256 bytes to keep replay size appropriate. Limit for car scripts is lower, only 32 bytes.
--- - While data will be interpolated between frames during reading, directional vectors won’t be re-normalized. 
--- - If two different apps would open a stream with the same layout, they’ll share a replay entry. Since 0.2.8, they’ll also share memory block, making `ac.ReplayStream()` act similar to `ac.connect()`.
--- - Each opened replay stream will persist through the entire AC session to be saved at the end. Currently, the limit is 320 streams per session (before 0.2.8, the limit was 128).
--- - Default values for unitialized frames are zeroes.
--- - Before 0.2.8, if game is launched in replay mode and there is no such data in replay, `ac.ReplayStream()` could return `nil`. Now, it’ll return the data, but it’ll be empty.
--- - Car scripts (both visual and physics) automatically add car ID and index to the key, ensuring uniqueness. Visual scripts can’t create new streams, but can access streams created by physics scripts, making it an effective way to pass data from physics to render, automatically being recorded in replays.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Unlike other similar functions, here you shouldn’t use string, otherwise data blending won’t work.
---@param callback fun()? @Callback that will be called when replay stops. Use this callback to re-apply data from structure: at the moment of the call it will contain stuff from last recorded frame allowing you to restore the state of a simulation to when replay mode was activated.
---@param frameDivisor integer? @Set to 2 to skip one out of two frames when recording, or 3 to skip two out of three frames. Default value: `1` (no skipping). Reduces replay size.
---@return T @Might return `nil` if there is game is launched in replay mode and there is no such data stored in the replay.
function ac.ReplayStream(layout, callback, frameDivisor)
  local layoutStr, reordered = __util.__si_build(layout)
  local s_name = __util.__si_ffi(layoutStr, true)
  local cached = _rpsActive[s_name]
  if cached == nil then
    local created = ffi.gc(ffi.C.lj_replayextension_new('__rps_'..tostring(ac.checksumXXH(layoutStr)), ffi.sizeof(s_name), __si_replayMixing(reordered), 
      callback and __util.setCallback(callback) or 0, tonumber(frameDivisor) or 1), ffi.C.lj_replayextension_gc)
    cached = {created, created._frame ~= nil and ffi.cast(s_name..'*', created._frame) or nil}
    _rpsActive[s_name] = cached
  end
  return __util.__si_proxy(layout, cached[2])
end

if __script.__test then
  __util.__si_replayMixing = __si_replayMixing
end

__definitions()

return ac.ReplayStream