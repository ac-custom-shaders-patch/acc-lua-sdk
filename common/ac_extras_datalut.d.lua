---Creates a new empty LUT. Use `ac.Lut:add(input, output)` to fill it with data.
---@return ac.DataLUT11
function ac.DataLUT11() end

---Parse LUT from a string in “(|X1=Y1|X2=Y2|…|)” format.
---@param data string @Serialized LUT data.
---@return ac.DataLUT11
function ac.DataLUT11.parse(data) end

---Load LUT file.
---@param filename string @LUT filename.
---@return ac.DataLUT11
function ac.DataLUT11.load(filename) end

---Load car data LUT file. Supports “data.acd” files as well.
---@param carIndex number @0-based car index.
---@param fileName string @Car data file name, such as `'power.lut'`.
---@return ac.DataLUT11
function ac.DataLUT11.carData(carIndex, fileName) end
