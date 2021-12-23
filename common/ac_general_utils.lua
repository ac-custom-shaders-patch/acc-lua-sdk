local _lapTimeEvaluation = nil

ffi.cdef[[
typedef struct {
  int estimated_lap_time_ms;
  int sectors_count;
  int* estimated_sector_time_ms;
} lua_time_evaluation;
]]

---Estimates lap time and sector times for main car using AC function originally used by Time Attack mode. Could be
---helpful in creating custom time attack modes. Uses “ideal_line.ai” from “track folder/data”, so might not work
---well with mods. If that file is missing, returns nil.
---@return {lapTimeMs: integer, sectorTimesMs: integer[]}|nil @Returns table with times in milliseconds, or `nil` if  “ideal_lane.ai” is missing.
function ac.evaluateLapTime()
  if not _lapTimeEvaluation then
    local data = ffi.C.lj_evaluate_lap_time()
    _lapTimeEvaluation = {
      lapTimeMs = data.estimated_lap_time_ms,
      sectorTimesMs = table.range(data.sectors_count, function (i, d) return i[d - 1] end, data.estimated_sector_time_ms)
    }
  end
  return _lapTimeEvaluation.lapTimeMs > 0 and _lapTimeEvaluation or nil
end
