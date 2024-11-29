---Creates a new empty 1D-to-1D LUT. Use `ac.DataLUT11:add(input, output)` to fill it with data.
---@return ac.DataLUT11
function ac.DataLUT11() end

---Parse 1D-to-1D LUT from a string in “(|Input1=Output1|Input2=Output2|…|)” format.
---@param data string @Serialized LUT data.
---@return ac.DataLUT11
function ac.DataLUT11.parse(data) end

---Load 1D-to-1D LUT file.
---@param filename string @LUT filename.
---@return ac.DataLUT11
function ac.DataLUT11.load(filename) end

---Load car data 1D-to-1D LUT file. Supports “data.acd” files as well.
---@param carIndex number @0-based car index.
---@param fileName string @Car data file name, such as `'power.lut'`.
---@return ac.DataLUT11
function ac.DataLUT11.carData(carIndex, fileName) end

---Creates a new empty 2D-to-1D LUT. Use `ac.DataLUT21:add(input, output)` to fill it with data.
---@return ac.DataLUT21
function ac.DataLUT21() end

---Parse 2D-to-1D LUT from a string in “(|X1,Y1=Output1|X2,Y2=Output2|…|)” format.
---@param data string @Serialized LUT data.
---@return ac.DataLUT21
function ac.DataLUT21.parse(data) end

---Load 2D-to-1D LUT file.
---@param filename string @LUT filename.
---@return ac.DataLUT21
function ac.DataLUT21.load(filename) end

---Load car data 2D-to-1D LUT file. Supports “data.acd” files as well.
---@param carIndex number @0-based car index.
---@param fileName string @Car data file name, such as `'speed_throttle.2dlut'`.
---@return ac.DataLUT21
function ac.DataLUT21.carData(carIndex, fileName) end
