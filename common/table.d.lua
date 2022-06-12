---Merges tables into one big table. Tables can be arrays or dictionaries, if it’s a dictionary same keys from subsequent tables will overwrite previously set keys.
---@generic T
---@param table T[]
---@vararg table
---@return T[]
function table.chain(table, ...) end