local ffi = require('ffi')

-- ---_@class MyEnum
-- ---_@class MyEnum.En
-- ---_@field BAZ MyEnum
-- local enum = ffi.new[[
-- struct{
--   static const int FOO = 0;
--   static const int BAR = 1;
--   static const int BAZ = 7;
--   static const int QUX = 8;
--   static const int QUUX = 12;
-- }
-- ]]

local enum = {
  BAZ = 7
}

---@alias MyEnum
---| 'enum.BAZ'  # BAR



expect(enum.BAZ, 7)


---@param arg MyEnum
function fn(arg) end

fn(enum.BAZ)
fn(enum.BAZ)
fn(10)
fn('enum.BAZ')
