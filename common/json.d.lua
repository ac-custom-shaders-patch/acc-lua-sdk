---Very basic JSON processing library. Based on json.lua by rxi, but a bit simplified and streamlined.
---In case you need to store and load data within Lua scripts, consider using `stringify()` and 
---`stringify.parse()` instead: it’s faster and more reliable.
JSON = {}

---Serializes a Lua entity (like a table) into a compact JSON.
---@param data table|number|string|boolean|nil
---@return string
function JSON.stringify(data) end

---Parses a compact JSON into a Lua entity. Note: if JSON is damaged, parser won’t throw an error, but
---results might be somewhat unpredictable. It’s an intended behaviour: in 99% of cases JSON parser
---used to exchange data with, for example, API endpoints, will receive correct data, but some of those
---AC JSON files are pretty screwed and often include things like missing commas, comments, etc.
---@param data string?
---@return any
function JSON.parse(data) end
