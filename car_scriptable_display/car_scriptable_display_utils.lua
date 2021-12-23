---Draw a mirror using mirror texture. Note: for optional rear view cameras turning on with reverse gear, consider using `[RENDERING_CAMERA_0]` 
---instead of mirror, both performance and quality will be better.
--[[@tableparam params {
  mirrorIndex: integer "Mirror index (for real mirrors)",
  pos: vec2 "Coordinates of the top left corner in pixels",
  size: vec2 "Size in pixels",
  color: rgbm = rgbm.colors.white "Mirror will be multiplied by this color",
  uvStart: vec2 = nil "UV coordinates of the top left corner, optional",
  uvEnd: vec2 = nil "UV coordinates of the bottom right corner, optional"
}]]
function display.mirror(params)
  local pos = params.pos          -- rect position
  local size = params.size        -- rect size
  local color = params.color      -- rect color
	local uvStart = params.uvStart  -- UV for upper left corner, optional
	local uvEnd = params.uvEnd      -- UV for bottom right corner, optional
  local mirrorIndex = params.mirrorIndex -- mirror index (for real mirrors)

  local uv = ac.getRealMirrorUV(mirrorIndex == nil and 1 or mirrorIndex)
  if uv.x ~= -1 then
    uvStart = vec2(uv.x, uv.y)
    uvEnd = vec2(uv.z, uv.w)
  end
  ui.drawImage('dynamic::mirror', pos, pos + size, color, uvStart, uvEnd)
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
    clicked = function(texStart, texSize, inCarPos, inCarRadius, repeatIntervalSeconds)
      if vec3.isvec3(texStart) then
        texStart, texSize, inCarPos, inCarRadius, repeatIntervalSeconds = nil, nil, texStart, texSize, inCarPos
      elseif not vec3.isvec3(inCarPos) then
        repeatIntervalSeconds, inCarPos, inCarRadius = inCarPos, nil, nil
      end
      local uv1 = texStart and texStart / resolution or vec2()
      local uv2 = texSize and texSize / resolution or vec2(1, 1)
      if repeatIntervalSeconds == nil then
        return function() return ac.isMeshClicked(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0) end
      end

      local timeToRepeat = 0
      return function()
        if ac.isMeshClicked(meshName, uv1, uv2) then
          timeToRepeat = repeatIntervalSeconds
          return true
        elseif timeToRepeat > 0 and ac.isMeshPressed(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0) then
          timeToRepeat = timeToRepeat - ac.getSim().dt
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
    pressed = function(texStart, texSize, inCarPos, inCarRadius)
      if vec3.isvec3(texStart) then
        texStart, texSize, inCarPos, inCarRadius = nil, nil, texStart, texSize
      end

      local uv1 = texStart and texStart / resolution or vec2()
      local uv2 = texSize and texSize / resolution or vec2(1, 1)
      local heldDown = 0
      return function()
        if heldDown > 0 then
          heldDown = ac.getUI().isMouseLeftKeyDown and math.max(0.01, heldDown - ac.getSim().dt) or heldDown - ac.getSim().dt
          return true
        end
        local holdPressed = ac.getUI().isMouseRightKeyDown or ac.getUI().isMouseMiddleKeyDown
        local meshPressed = ac.isMeshPressed(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0)
          or holdPressed and ac.isMeshHovered(meshName, uv1, uv2, __util.ensure_vec3_nil(inCarPos), tonumber(inCarRadius) or 0)
        if meshPressed and holdPressed then
          heldDown = 3
        end
        return meshPressed
      end
    end
  }
end
