---Display namespace with helper functions for creating dynamic textures.
display = {}

---Draw a rectangle.
--[[@tableparam params {
  pos: vec2 "Coordinates of the top left corner in pixels",
  size: vec2 "Size in pixels",
  color: rgbm = rgbm.colors.white "Rectangle color"
}]]
function display.rect(params)
  local pos = params.pos      -- rect position
  local size = params.size    -- rect size
  local color = params.color  -- rect color
  ui.drawRectFilled(pos, pos + size, color)
end

---Draw an image.
---
---If you’re drawing a lot of different images, consider combining them into a single atlas and using
---`uvStart`/`uvEnd` to specify the region.
--[[@tableparam params {
  image: string "Path to image to draw",
  pos: vec2 "Coordinates of the top left corner in pixels",
  size: vec2 "Size in pixels",
  color: rgbm = rgbm.colors.white "Image will be multiplied by this color",
  uvStart: vec2 = vec2(0, 0) "UV coordinates of the top left corner",
  uvEnd: vec2 = vec2(1, 1) "UV coordinates of the bottom right corner"
}]]
function display.image(params)
  local image = params.image      -- image source
  local pos = params.pos          -- image position
  local size = params.size        -- image size
  local color = params.color      -- image tint
	local uvStart = params.uvStart  -- UV for upper left corner, optional
	local uvEnd = params.uvEnd      -- UV for bottom right corner, optional
  ui.drawImage(image, pos, pos + size, color, uvStart, uvEnd)
end

---Draw text using AC font.
--[[@tableparam params {
  text: string "Text to draw",
  pos: vec2 "Coordinates of the top left corner in pixels",
  letter: vec2 = vec2(20, 40) "Size of each letter",
  font: string = 'aria' "AC font to draw text with, either from “content/fonts” or from a folder with a script (can refer to a subfolder)",
  color: rgbm = rgbm.colors.white "Text color",
  alignment: number = 0 "0 for left, 0.5 for center, 1 for middle, could be anything in-between. Set `width` as well so it would know in what area to align text.",
  width: number = 200 "Required for non-left alignment",
  spacing: number = 0 "Additional offset between characters, could be either positive or negative"
}]]
function display.text(params)
  local text = tostring(params.text)   -- text to draw
  local pos = params.pos               -- text position, optional
  local letter = params.letter         -- size of each letter
  local font = params.font             -- name of font, optional
  local color = params.color           -- color, optional
  local width = params.width or 0      -- width, optional
  local alignment = params.alignment   -- alignment, optional (0.5 for center, 1 for right)
  local spacing = params.spacing or 0  -- extra spacing between letters

  local textLen = #text
  if textLen == 0 then return end
  
  local actualWidth = letter.x * textLen + (textLen > 0 and spacing * (textLen - 1) or 0)
  if width > actualWidth then
    pos.x = pos.x + (width - actualWidth) * alignment
  end

  if font ~= nil then ui.pushACFont(font) end
  if pos ~= nil then ui.setCursor(pos) end  
  ui.acText(text, letter, spacing, color)
  if font ~= nil then ui.popACFont() end
end

---Draw simple horizontal bar (like progress bar) consisting of several sections.
--[[@tableparam params {
  text: string "Text to draw",
  pos: vec2 "Coordinates of the top left corner of the bar in pixels",
  size: vec2 = vec2(200, 40) "Size of the whole bar",
  delta: number = 8 "Distance between elements",
  activeColor: rgbm = rgbm.colors.white "Active color",
  inactiveColor: rgbm = rgbm.colors.transparent "Inactive color",
  total: integer = 12 "Total number of sections",
  active: integer = 8 "Number of active sections"
}]]
function display.horizontalBar(params)
  local pos = params.pos      -- bar position
  local size = params.size    -- bar size
  local delta = params.delta  -- distance between elements
  local activeColor = params.activeColor -- active color
  local inactiveColor = params.inactiveColor -- inactive color
  local total = params.total
  local active = params.active
  local itemSize = (size.x - delta * (total - 1)) / total
  for i = 1, total do
    ui.drawRectFilled(pos, pos + vec2(itemSize, size.y), i <= active and activeColor or inactiveColor)
    pos = pos + vec2(itemSize + delta, 0)
  end
end
