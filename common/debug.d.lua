---Displays value in Lua Debug app, great for tracking state of your values live.
---@param key string
---@param value any?
---@overload fun(key: string, value: number, min: number?, max: number?, collect: integer?, collectMode: ac.DebugCollectMode?) @Variant with fixed range for a graph in Lua Debug app. Set `collect` to a value above 1 if you need Lua Debug App to combine a few values so that graph would move slower. Parameter `collectMode` can specify the way in which values will be combined.
function ac.debug(key, value) end