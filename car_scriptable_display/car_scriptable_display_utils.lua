--[[? if (ctx.ldoc) out(]]

---@class display.DrawnMirror
local _drawnMirror = {}

---Simple helper function taking a world coordinate and returning a point on drawn mirror corresponding to it, or `nil` if projection is not
---available or the point is behind the mirror view. Returned coordinate can be outside of mirror area. Check second returned value to
---verify if point is inside or outside.
---@param pos vec3 @Point in world coordinates.
---@return vec2? @Returns 2D coordinate in the same units `display.mirror()` parameters `pos` and `size`, or `nil` if projection is not available.
---@return boolean? @Returns `false` if projection is not available, or if it is, but the point is outside of mirror.
function _drawnMirror:project(pos) end

--[[); else out(]]

local _drawnMirror

--[[) ?]]

---Draw a mirror using mirror texture. Note: for optional rear view cameras turning on with reverse gear, consider using `[RENDERING_CAMERA_0]` 
---instead of mirror, both performance and quality will be better (as long as you would turn if off when not using though).
---
---Before CSP 0.2.5, worked pretty badly, especially with Real Mirrors disabled. Now, should work better, pretty seamlessly in general. Still,
---when setting it up it’s advisable to test things with Real Mirrors on and off, and possibly tweak `alignX` parameter.
---
---Note: since the function is meant for displays, it would work the best if mirror selected would be configured to work as monitor. Add
---`[REAL_MIRROR_0] IS_MONITOR = 1` in car config to set a mirror to act as a monitor.
--[[@tableparam params {
  mirrorIndex: integer "0-based mirror index (for Real Mirrors)",
  pos: vec2 "Coordinates of the top left corner in pixels",
  size: vec2 "Size in pixels",
  color: rgbm = rgbm.colors.white "Mirror will be multiplied by this color",
  ratio: number = 1 "Optional ratio adjustment multiplier",
  alignX: number = 0 "Value from -1 to 1 shifting mirror texture horizontally (applicable especially if Real Mirrors are disabled)",
  alignY: number = 0 "Value from -1 to 1 shifting mirror texture vertically"
}]]
---@return display.DrawnMirror
function display.mirror(params)
  local pos = params.pos          -- rect position
  local size = params.size        -- rect size
  local color = params.color      -- rect color
  local ratioAdj = params.ratio or 1
  local alignX = params.alignX or 0
  local alignY = params.alignY or 0
  local mirrorIndex = params.mirrorIndex or 1 -- mirror index (for real mirrors)

  local uvX, uvY, uvZ, uvW, uvR = __util.native('lj_getRealMirrorUV', mirrorIndex)
  local imageSizeX, imageSizeY
  if uvX then
    imageSizeX, imageSizeY = ratioAdj * 4 * uvR / (uvZ - uvX), uvW - uvY
  else
    uvX, uvY = 0, 0
    uvZ, uvW = 1, 1
    imageSizeX, imageSizeY = ratioAdj * 4, 1
  end

  local multX, multY = size.x / (imageSizeX * (uvZ - uvX)), size.y  / (imageSizeY * (uvW - uvY))
  local uv_sX, uv_sY = uvZ - uvX, uvW - uvY
  local uv_cX, uv_cY = (uvX + uvZ) / 2, (uvY + uvW) / 2

  local uvStart, uvEnd
  if multX > multY then
    local hs = uv_sY * 0.5 * (multY / multX)
    uv_cY = math.lerp(uvY + hs, uvW - hs, 0.5 + 0.5 * alignY)
    uvStart = vec2(uv_cX + uv_sX * 0.5, uv_cY - hs)
    uvEnd = vec2(uv_cX - uv_sX * 0.5, uv_cY + hs)
  else
    local hs = uv_sX * 0.5 * (multX / multY)
    uv_cX = math.lerp(uvX + hs, uvZ - hs, 0.5 + 0.5 * alignX)
    uvStart = vec2(uv_cX + hs, uv_cY - uv_sY * 0.5)
    uvEnd = vec2(uv_cX - hs, uv_cY + uv_sY * 0.5)
  end

  local posEnd = pos + size
  ui.beginTonemapping()
  ui.drawImage('dynamic::mirror', pos, pos + size, color, uvStart, uvEnd)
  ui.endTonemapping(0, 0, true)
  if not _drawnMirror then
    _drawnMirror = {
      __index = {
        project = function (self, pos)
          local ppx, ppy =  __util.native('lj_getRealMirrorUV_proj', self.mirrorIndex, pos)
          if ppx then
            ppx = math.remap(ppx, self.uv1.x, self.uv2.x, self.pos1.x, self.pos2.x)
            ppy = math.remap(ppy, self.uv1.y, self.uv2.y, self.pos1.y, self.pos2.y)
            return vec2(ppx, ppy), ppx >= self.pos1.x and ppx <= self.pos2.x and ppy >= self.pos1.y and ppy <= self.pos2.y
          else
            return nil, false
          end
        end
      }
    }
  end
  return setmetatable({ pos1 = pos, pos2 = posEnd, uv1 = uvStart, uv2 = uvEnd, mirrorIndex = mirrorIndex }, _drawnMirror)
end

---Interactive mesh constructor. Takes mesh name (or filter referring to multiple meshes) and optional resolution, returns
---an object which can be used to create listeners for different events on different regions of original meshes.
--[[@tableparam params {
  mesh: string "Mesh name or filter. To refer to several meshes, use curly brackets and list them like so: `mesh = '{ meshName1, meshName2 }'`",
  resolution: vec2 = vec2(1024, 1024) "Resolution of original texture in case you would want to specify UV regions to filter out events"
}]]
---@return display.InteractiveMeshFactory
function display.interactiveMesh(params)
  local meshName = params.mesh
  local resolution = params.resolution or vec2(1, 1)
  return {
    clicked = function(texStart, texSize, inCarPos, inCarRadius, inCarLocalPos, repeatIntervalSeconds)
			if vec3.isvec3(texStart) then
				texStart, texSize, inCarPos, inCarRadius, inCarLocalPos, repeatIntervalSeconds = nil, nil, texStart, texSize, inCarPos, inCarRadius
			elseif not vec3.isvec3(inCarPos) then
				repeatIntervalSeconds, inCarPos, inCarRadius = inCarPos, nil, nil
			end
			if type(inCarLocalPos) ~= 'boolean' then
				inCarLocalPos, repeatIntervalSeconds = repeatIntervalSeconds, inCarLocalPos
			end
      local uv1 = texStart and texStart / resolution or vec2()
      local uv2 = texSize and texSize / resolution or vec2(1, 1)
      if repeatIntervalSeconds == nil then
        return function() return ac.isMeshClicked(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0, inCarLocalPos == true) end
      end

      local timeToRepeat = 0
      return function()
        if ac.isMeshClicked(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0, inCarLocalPos == true) then
          timeToRepeat = repeatIntervalSeconds
          return true
        elseif timeToRepeat > 0 and ac.isMeshPressed(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0, inCarLocalPos == true) then
          timeToRepeat = timeToRepeat - ac.getScriptDeltaT()
          if timeToRepeat <= 0 then
            timeToRepeat = repeatIntervalSeconds
            return true
          end
        else
          timeToRepeat = 0
          return false
        end
      end
    end,
    pressed = function(texStart, texSize, inCarPos, inCarRadius, inCarLocalPos)
			if vec3.isvec3(texStart) then
				texStart, texSize, inCarPos, inCarRadius, inCarLocalPos = nil, nil, texStart, texSize, inCarPos
			end
      local uv1 = texStart and texStart / resolution or vec2()
      local uv2 = texSize and texSize / resolution or vec2(1, 1)
      local heldDown = 0
      return function()
        if heldDown > 0 then
          heldDown = ac.getUI().isMouseLeftKeyDown and math.max(0.01, heldDown - ac.getScriptDeltaT()) or heldDown - ac.getScriptDeltaT()
          return true
        end
        local holdPressed = ac.getUI().isMouseRightKeyDown or ac.getUI().isMouseMiddleKeyDown
        local meshPressed = ac.isMeshPressed(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0, inCarLocalPos == true)
          or holdPressed and ac.isMeshHovered(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0, inCarLocalPos == true)
        if meshPressed and holdPressed then
          heldDown = 3
        end
        return meshPressed
      end
    end
  }
end
