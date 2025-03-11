__source 'lua/api_extras_tracklines.cpp'
require './common/internal_import'

ffi.cdef [[ 
typedef struct {
  mat4x4 transform;
  vec3 _cur_point;
  float castStep;
  float paddingSize;
  float defaultThickness;
  float ageFactor;
  float bulgeFactor;
  bool forceRecast;
  bool alignShapes;
} tracklines_data;
]]

local tld_data

---Easily add new lines on a track. Automatically tries to align with track height, but correct Y coordinate is still very welcome (just use
---the actual track Y coordinate, offsets to avoid clipping issues will be added automatically).
---
---If you want to draw many lines of a flat surface, consider setting `.castStep` to `math.huge` so that raycasts would be mostly skipped. If
---you find API lacking certain things, or performance not being enough, please contact me and I’ll add missing capabilities.
---@class ac.TrackPaint
---@field transform mat4x4 @Transformation matrix.
---@field castStep number @Gap between rays cast against physical surface. Default value: 0.5 (two rays per meter). Set to `math.huge` to disable pretty much all casts if you need to add a ton of things drawn on a flat surface.
---@field paddingSize number @Padding size in meters. Set to 0 to disable thickness entirely (not recommended).
---@field defaultThickness number @Line thickness in meters used if thickness is not specified. Default value: 0.1.
---@field ageFactor number @How aged do lines look. Default value: 0.5.
---@field bulgeFactor number @How thick (vertically) is the paint. At default value, 0.25, it’ll be about 5 mm thick. Helps to see lines from grazing angles. Won’t have an effect if `.paddingSize` is set to 0. Default value: 0.25.
---@field forceRecast boolean @Set to `true` to force surface recast for lines, images and shapes (by default, recast only activates on uneven surfaces).
---@field alignShapes boolean @Set to `false` to disable shapes (such as `:circle()` or `:rect()`) alignment on the surface (they will be projected as if ground is flat, with XZ unchanging).
---@explicit-constructor ac.TrackPaint
ffi.metatype('tracklines_data', {
  __index = {
    ---Destroy everything and release resources.
    release = function (s)      
      table.removeItem(tld_data.i, s)
      return __util.native('lj_tld_release', s)
    end,

    ---Reset content, including drawn shapes, textures or shapes being drawn with `:to()`.
    ---@return self
    reset = function (s)
      return __util.native('lj_tld_reset', s)
    end,

    ---A shortcut to quickly set `.ageFactor` value (useful if you want to chain multiple calls together).
    ---@param value number? @Age factor from 0 to 1. Default value: 0.5.
    ---@return self
    age = function (s, value)
      s.ageFactor = tonumber(value) or 0.5
      return s
    end,

    ---A shortcut to quickly set `.bulgeFactor` value (useful if you want to chain multiple calls together).
    ---@param value number? @Bulge factor from 0 to 1. Default value: 0.25.
    ---@return self
    bulge = function (s, value)
      s.bulgeFactor = tonumber(value) or 0.25
      return s
    end,

    ---A shortcut to quickly set `.paddingSize` value (useful if you want to chain multiple calls together).
    ---@param value number? @Padding size in meters. Default value: 0.03.
    ---@return self
    padding = function (s, value)
      s.paddingSize = tonumber(value) or 0.03
      return s
    end,

    ---Quickly add a separate straight line. Does a bit of raycasting and surface alignment depending on current values of `castStep` and `forceRecast`.
    ---
    ---Padding (see `.paddingSize`) is added to the line. This means that with large enough padding, line will appear larger.
    ---@param from vec3 @World position for first point of a line.
    ---@param to vec3 @World positoon for the last point of a line.
    ---@param color rgbm? @Line color. Default value: `rgbm.colors.white`.
    ---@param thickness number? @Thickness in meters. If not set, `.defaultThickness` will be used.
    ---@return self
    line = function (s, from, to, color, thickness)
      return __util.native('lj_tld_addline', s, from, to, color, thickness)
    end,

    ---Quickly add an image. Does a bit of raycasting and surface alignment depending on current values of `castStep` and `forceRecast`.
    ---Only four unique textures are allowed per `ac.TrackPaint()` instance. If you need more and the best performance, use atlases and texture coordinates.
    ---Raises an error if there are too many textures set already.
    ---
    ---Size of the resulting image is guaranteed to match input `size` no matter the padding (see `.paddingSize`). This means that with large enough padding,
    ---image edges will be cut off.
    ---@param image string @Texture name or image, such as `ui.decodeImage()` output.
    ---@param pos vec3 @World position of an image.
    ---@param size number|vec2 @Size in meters.
    ---@param angle number? @Angle in degrees. Default value: `0`.
    ---@param color rgbm? @Optional color multiplying the texture color.
    ---@param uv1 vec2? @Texture coordinates for the top left corner. Should be within 0…1 range. Default value: `vec2(0, 0)`. 
    ---@param uv2 vec2? @Texture coordinates for the bottom right corner. Should be within 0…1 range. Default value: `vec2(1, 1)`.
    ---@return self
    image = function (s, image, pos, size, angle, color, uv1, uv2)
      return __util.native('lj_tld_addimage', s, image, pos, size, angle, color, uv1, uv2)
    end,

    ---For advanced cases, use carefully. All shapes drawn between `:textureStart()` and subsequent `:textureEnd()` calls will get a texture mapped onto them.
    ---Only four unique textures are allowed per `ac.TrackPaint()` instance. If you need more and the best performance, use atlases and texture coordinates.
    ---Raises an error if there are too many textures set already.
    ---@return self
    textureStart = function (s)
      return __util.native('lj_tld_starttex', s)
    end,

    ---For advanced cases, use carefully. All shapes drawn between `:textureStart()` and subsequent `:textureEnd()` calls will get a texture mapped onto them.
    ---Only four unique textures are allowed per `ac.TrackPaint()` instance. If you need more and the best performance, use atlases and texture coordinates.
    ---Raises an error if there are too many textures set already.
    ---@param image string @Texture name or image, such as `ui.decodeImage()` output.
    ---@param pivot vec3 @World position of top left corner of the texture.
    ---@param offsetX vec3 @World offset corresponding with horizontal direction of the image.
    ---@param offsetY vec3 @World offset corresponding with vertical direction of the image.
    ---@param uv1 vec2? @Texture coordinates for the top left corner. Should be within 0…1 range. Default value: `vec2(0, 0)`. 
    ---@param uv2 vec2? @Texture coordinates for the bottom right corner. Should be within 0…1 range. Default value: `vec2(1, 1)`.
    ---@return self
    textureEnd = function (s, image, pivot, offsetX, offsetY, uv1, uv2)
      return __util.native('lj_tld_endtex', s, image, pivot, offsetX, offsetY, uv1, uv2)
    end,

    ---Quickly add text. Does a bit of raycasting and surface alignment.
    ---Only four unique textures are allowed per `ac.TrackPaint()` instance, and each unique font used here counts as a texture.
    ---
    ---Value `.paddingSize` has no effect on this function.
    ---@param font string @Font name. Refers to font in “content/fonts”, or in the script folder (same logic as with `ui.pushACFont()`).
    ---@param text string @Text to draw.
    ---@param pos vec3 @World position of an image.
    ---@param size number|vec2 @Size in meters. Text will be fit within that area while preserving aspect ratio.
    ---@param angle number? @Angle in degrees. Default value: `0`.
    ---@param color rgbm? @Optional color multiplying the texture color.
    ---@param aspectRatio number? @Optional aspect ratio modifier. Decrease to stretch font vertically. Default value: `0`.
    ---@return self
    text = function (s, font, text, pos, size, angle, color, aspectRatio)
      return __util.native('lj_tld_addtext', s, font, text, pos, size, angle, color, aspectRatio)
    end,

    ---Call multiple times to generate a list of points, and then turn them into a line or a figure using `:stroke()` or `:fill()`. 
    ---Doesn’t do anything if position is too close to previously added position.
    ---@param pos vec3? @Position to move spline to. If `nil`, does nothing.
    ---@param segments integer? @Explicitly specify number of segments (not recommended, but if you need to draw a complex shape on a flat surface, maybe set it to 1).
    ---@return self
    to = function (s, pos, segments)
      if vec3.isvec3(pos) then
        ffi.C.lj_tld_lineto(s, pos, tonumber(segments) or 0)
      end
      return s
    end,

    ---Draw an arc. Connects current position (last call to `:to()`) to the beginning of the arc. Call `:stroke()` or `:fill()` to finish the shape.
    ---@param center vec3 @Arc’s center.
    ---@param radius number @Arc radius, must be positive.
    ---@param startAngle number @The angle at which the arc starts in degrees, measured from the positive x-axis.
    ---@param endAngle number @The angle at which the arc ends in degrees, measured from the positive x-axis.
    ---@param anticlockwise boolean? @An optional boolean value. If true, draws the arc counter-clockwise between the start and end angles. Default value: `false` (clockwise).
    ---@param segments integer? @Segments for the entire circle (similar to `:circle()`).
    ---@return self
    arc = function (s, center, radius, startAngle, endAngle, anticlockwise, segments)
      startAngle = math.rad(startAngle)
      endAngle = math.rad(endAngle)
      local deltaAngle = endAngle - startAngle

      if anticlockwise then
        if deltaAngle >= 0 then
          deltaAngle = deltaAngle - math.tau
        end
      else
        if deltaAngle <= 0 then
          deltaAngle = deltaAngle + math.tau
        end
      end

      segments = segments and math.clamp(segments, 3, 100) or math.clamp(radius * 12, 20, 40)
      segments = math.max(1, math.ceil(math.abs(deltaAngle) / (math.tau / segments)))
      local angleStep = deltaAngle / segments
      s._cur_point:set(math.cos(startAngle) * radius, 0, math.sin(startAngle) * radius):add(center)
      ffi.C.lj_tld_linecommit(s)
      for i = 1, segments do
        local angle = startAngle + i * angleStep
        s._cur_point:set(math.cos(angle) * radius, 0, math.sin(angle) * radius):add(center)
        ffi.C.lj_tld_linecommit(s)
      end
      return s
    end,

    ---Draw an arc from the current point to the target point. If `:to()` wasn’t called, it’ll start from 0.
    ---Call `:stroke()` or `:fill()` to finish the shape.
    ---
    ---Mirrors JavaScript’s canvas call: <https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/arcTo>.
    ---@param point1 vec3 @Arc’s first control point.
    ---@param point2 vec3 @Arc’s second control point.
    ---@param radius number? @Arc radius, must be positive. If not set or above maximum reasonable value, will be set to that value.
    ---@param segments integer? @Segments for the entire circle (similar to `:circle()`).
    ---@return self
    arcTo = function (s, point1, point2, radius, segments)
      local v1 = vec2(s._cur_point.x - point1.x, s._cur_point.z - point1.z)
      local v2 = vec2(point2.x - point1.x, point2.z - point1.z)
      local l1, l2 = v1:length(), v2:length()
      local v1_norm = v1:scale(1 / l1)
      local v2_norm = v2:scale(1 / l2)

      local angle = math.acos(v1_norm:dot(v2_norm))
      if angle <= 0.001 or angle >= math.pi - 0.001 or radius < 0.01 then
        s:to(point1)
        return
      end
    
      local tanValue = math.tan(angle / 2)
      local maxRadius = math.min(l1, l2) * tanValue
      if not radius or radius > maxRadius then radius = maxRadius end
      local tangentLength = radius / tanValue    
      local tangentPoint1 = vec3(v1_norm.x * tangentLength, 0, v1_norm.y * tangentLength):add(point1)
      local tangentPoint2 = vec3(v2_norm.x * tangentLength, 0, v2_norm.y * tangentLength):add(point1)
    
      s:to(tangentPoint1, 1)    
      local cross = v1_norm.x * v2_norm.y - v1_norm.y * v2_norm.x
      local anticlockwise = cross > 0
      local bisector = (v1_norm + v2_norm):normalize()
      local sinHalfAngle = math.sin(angle / 2)
      local distance = radius / sinHalfAngle
      local center = vec3(bisector.x * distance, 0, bisector.y * distance):add(point1)    
      local startAngle = math.atan2(tangentPoint1.z - center.z, tangentPoint1.x - center.x)
      local endAngle = math.atan2(tangentPoint2.z - center.z, tangentPoint2.x - center.x)
      return s:arc(center, radius, math.deg(startAngle), math.deg(endAngle), anticlockwise, segments)
    end,

    ---Draw a quadratic curve from the current point to the target point. If `:to()` wasn’t called, it’ll start from 0.
    ---Call `:stroke()` or `:fill()` to finish the shape.
    ---
    ---Mirrors JavaScript’s canvas call: <https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/quadraticCurveTo>.
    ---@param controlPoint vec3 @Control point for the curve.
    ---@param endPoint vec3 @Final point.
    ---@param segments integer? @Number of segments. Default value: 20.
    ---@return self
    quadraticCurveTo = function(s, controlPoint, endPoint, segments)
      local startPoint = s._cur_point:clone()
      segments = math.clamp(tonumber(segments) or 20, 1, 100)
      for i = 1, segments do
        local t = i / segments
        local u = 1 - t
        s._cur_point:setScaled(startPoint, u * u):addScaled(controlPoint, 2 * u * t):addScaled(endPoint, t * t)
        ffi.C.lj_tld_linecommit(s)
      end
      return s
    end,

    ---Draw a bezier curve from the current point to the target point. If `:to()` wasn’t called, it’ll start from 0.
    ---Call `:stroke()` or `:fill()` to finish the shape.
    ---
    ---Mirrors JavaScript’s canvas call: <https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/bezierCurveTo>.
    ---@param controlPoint1 vec3
    ---@param controlPoint2 vec3
    ---@param endPoint vec3
    ---@return self
    bezierCurveTo = function(s, controlPoint1, controlPoint2, endPoint)
      local function recursiveBezier(p0, p1, p2, p3)
        -- Calculate the midpoints of the line segments
        local p01 = p0:clone():add(p1):scale(0.5)
        local p12 = p1:clone():add(p2):scale(0.5)
        local p23 = p2:clone():add(p3):scale(0.5)
        local p012 = p01:clone():add(p12):scale(0.5)
        local p123 = p12:add(p23):scale(0.5)
        local p0123 = p012:clone():add(p123):scale(0.5)
    
        local dx = p3.x - p0.x
        local dy = p3.z - p0.z
        local d1 = math.abs((p1.x - p3.x) * dy - (p1.z - p3.z) * dx)
        local d2 = math.abs((p2.x - p3.x) * dy - (p2.z - p3.z) * dx)
        if d1 + d2 < 0.005 then
          s:to(p3)
        else
          recursiveBezier(p0, p01, p012, p0123)
          recursiveBezier(p0123, p123, p23, p3)
        end
      end
    
      local startPoint = s._cur_point:clone()
      recursiveBezier(startPoint, controlPoint1, controlPoint2, endPoint)
      s:to(endPoint)
      return s
    end,

    ---Turn points added with `:to()` into a line.
    ---@param closed boolean? @If set to `true`, closes points into a figure. Default value: `false`.
    ---@param color rgbm? @Line color. Default value: `rgbm.colors.white`.
    ---@param thickness number? @Thickness in meters. If not set, `.defaultThickness` will be used.
    ---@return self
    stroke = function (s, closed, color, thickness) 
      return __util.native('lj_tld_stroke', s, closed, color, thickness)
    end,

    ---Call this function to configure dash pattern. Pass an array specifying alternating lengths of lines and gaps. Pass `nil` or empty table to disable dashes.
    ---
    ---When using, keep in mind `.paddingSize`, it could make lines visually longer.
    ---@param pattern number[]? @Lengths of dashes and lines in meters. If the number of elements in the array is odd, the elements of the array get copied and concatenated.
    ---@return self
    strokeDash = function (s, pattern, colors) 
      return __util.native('lj_tld_dash', s, pattern, colors)
    end,

    ---Call this function if you want to draw parallel lines when calling `:stroke()` or using shape functions. Up to four parallel lines at once can be drawn. Call it again
    ---with `nil`, empty table or table containing one element to reset the pattern. Raises an error if you’ll pass more than 8 elements thus trying to draw more than 4 lines at once.
    ---
    ---When using, keep in mind `.paddingSize`, it could make lines visually wider.
    ---@param pattern number[]? @Width of the first line, space between first and second, width of the second line, etc. Total width will be normalized to match stroke width.
    ---@param colors (rgbm|false)[]? @If set, allows to override colors for specific lines. Pass `false` to keep original color. If `pattern` is empty or defines less than two lines, ignored.
    ---@param dashes (number[]|false)[]? @If set, overrides dash pattern for specific lanes. The most expensive option to draw (but still faster than repeating calls in Lua).
    ---@return self
    strokePattern = function (s, pattern, colors, dashes) 
      return __util.native('lj_tld_crosshape', s, pattern, colors, dashes)
    end,

    ---Turn points added with `:to()` into a shape. Shape can be concave, but be vary of how points are arranged: algorithm used for triangulating
    ---a set of points might crash or get stuck with strange cases.
    ---
    ---If you want to add a hole to the generated mesh, first add its outline using `:to()`, then call `:fillHole()`, and after that add points to
    ---the outer area using `:to()` and call `:fill()` to finalize the result.
    ---
    ---Sometimes triangulation process can be helped with `:fillHint()`.
    ---@param color rgbm? @Shape color. Default value: `rgbm.colors.white`.
    ---@return self
    fill = function (s, color)
      return __util.native('lj_tld_fill', s, color)
    end,

    ---Turn points added with `:to()` to a hole for a subsequent `:fill()` call. Note: holes can’t touch outer perimeter. Also, a shape can’t have
    ---intersecting or touching holes.
    ---@return self
    fillHole = function (s) 
      return __util.native('lj_tld_fillhole', s)
    end,

    ---Add a separate vertex to a subsequent `:fill()` call. Could be useful to hint triangulation process.
    ---@param pos vec3 @Point position.
    ---@return self
    fillHint = function (s, pos)
      return __util.native('lj_tld_fillhint', s, pos)
    end,

    ---Quickly add a circle. If `thickness` is `false` or not set, circle will be filled.
    ---@param pos vec3 @Circle position.
    ---@param radius number? @Circle radius in meters. Default value: 1.
    ---@param thickness boolean|number? @Pass `true` to use `.defaultThickness`. Default value: `false` (filled circle).
    ---@param color rgbm? @Color. Default value: `rgbm.colors.white`.
    ---@param segments integer? @Number of segments. Should be between 3 and 100. If not set, guessed based on radius.
    ---@return self
    circle = function (s, pos, radius, thickness, color, segments)
      ffi.C.lj_tld_shapehelper(s, pos, 0)
      radius = tonumber(radius) or 1
      segments = tonumber(segments)
      segments = segments and math.clamp(segments, 3, 100) or math.clamp(radius * 12, 20, 40)
      for i = 0, segments - 1 do
        local ta = i / segments * (math.pi * 2)
        local ts, tc = math.sin(ta), math.cos(ta)
        ffi.C.lj_tld_shapehelper_step(s, tc * radius, ts * radius)
      end
      if thickness == true then
        thickness = s.defaultThickness
      end
      return thickness and s:stroke(true, color, thickness) or s:fill(color)
    end,

    ---Quickly add an ellipse. If `thickness` is `false` or not set, ellipse will be filled.
    ---@param pos vec3 @Ellipse position.
    ---@param radii vec2 @Ellipse radii in meters.
    ---@param angle number? @Ellipse orientation. Default value: 0.
    ---@param thickness boolean|number? @Pass `true` to use `.defaultThickness`. Default value: `false` (filled ellipse).
    ---@param color rgbm? @Color. Default value: `rgbm.colors.white`.
    ---@param segments integer? @Number of segments. Should be between 3 and 100. If not set, guessed based on radius.
    ---@return self
    ellipse = function (s, pos, radii, angle, thickness, color, segments)
      ffi.C.lj_tld_shapehelper(s, pos, tonumber(angle) or 0)
      segments = tonumber(segments)
      segments = segments and math.clamp(segments, 3, 100) or math.clamp(math.max(radii.x, radii.y) * 12, 20, 40)
      for i = 0, segments - 1 do
        local ta = i / segments * (math.pi * 2)
        local ts, tc = math.sin(ta), math.cos(ta)
        ffi.C.lj_tld_shapehelper_step(s, tc * radii.x, ts * radii.y)
      end
      if thickness == true then thickness = s.defaultThickness end
      return thickness and s:stroke(true, color, thickness) or s:fill(color)
    end,

    ---Quickly add a rect. If `thickness` is `false` or not set, rect will be filled.
    ---@param pos vec3 @Rect position.
    ---@param size vec2 @Rect size in meters.
    ---@param angle number? @Rect orientation. Default value: 0.
    ---@param thickness boolean|number? @Pass `true` to use `.defaultThickness`. Default value: `false` (filled rect).
    ---@param color rgbm? @Color. Default value: `rgbm.colors.white`.
    ---@param cornerRadius number? @Corner radius. Default value: `0`.
    ---@return self
    rect = function (s, pos, size, angle, thickness, color, cornerRadius)
      cornerRadius = math.min(tonumber(cornerRadius) or 0, math.min(size.x, size.y) / 2)
      ffi.C.lj_tld_shapehelper(s, pos, tonumber(angle) or 0)
      if cornerRadius <= 0.05 then
        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, -size.y / 2)
        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, size.y / 2)
        ffi.C.lj_tld_shapehelper_step(s, size.x / 2, size.y / 2)
        ffi.C.lj_tld_shapehelper_step(s, size.x / 2, -size.y / 2)
      else
        local angs = tld_data.cr
        if not angs then
          angs = {}
          tld_data.cr = angs
          for i = 1, 7 do
            local ta = i / 8 * (math.pi / 2)
            local ts, tc = math.sin(ta), math.cos(ta)
            angs[i] = {1 - tc, 1 - ts}
          end
        end
        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2 + cornerRadius, -size.y / 2)
        for i = 1, 7 do
          ffi.C.lj_tld_shapehelper_step(s, -size.x / 2 + cornerRadius * angs[i][2], -size.y / 2 + cornerRadius * angs[i][1])
        end
        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, -size.y / 2 + cornerRadius)

        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, size.y / 2 - cornerRadius)
        for i = 1, 7 do
          ffi.C.lj_tld_shapehelper_step(s, -size.x / 2 + cornerRadius * angs[i][1], size.y / 2 - cornerRadius * angs[i][2])
        end
        ffi.C.lj_tld_shapehelper_step(s, -size.x / 2 + cornerRadius, size.y / 2)

        ffi.C.lj_tld_shapehelper_step(s, size.x / 2 - cornerRadius, size.y / 2)
        for i = 1, 7 do
          ffi.C.lj_tld_shapehelper_step(s, size.x / 2 - cornerRadius * angs[i][2], size.y / 2 - cornerRadius * angs[i][1])
        end
        ffi.C.lj_tld_shapehelper_step(s, size.x / 2, size.y / 2 - cornerRadius)

        ffi.C.lj_tld_shapehelper_step(s, size.x / 2, -size.y / 2 + cornerRadius)
        for i = 1, 7 do
          ffi.C.lj_tld_shapehelper_step(s, size.x / 2 - cornerRadius * angs[i][1], -size.y / 2 + cornerRadius * angs[i][2])
        end
        ffi.C.lj_tld_shapehelper_step(s, size.x / 2 - cornerRadius, -size.y / 2)
      end
      if thickness == true then thickness = s.defaultThickness end
      return thickness and s:stroke(true, color, thickness) or s:fill(color)
    end,

    ---Quickly add a triangle. If `thickness` is `false` or not set, triangle will be filled.
    ---@param pos vec3 @Triangle position.
    ---@param size vec2 @Triangle size in meters.
    ---@param angle number? @Triangle orientation. Default value: 0.
    ---@param thickness boolean|number? @Pass `true` to use `.defaultThickness`. Default value: `false` (filled triangle).
    ---@param color rgbm? @Color. Default value: `rgbm.colors.white`.
    ---@return self
    triangle = function (s, pos, size, angle, thickness, color)
      ffi.C.lj_tld_shapehelper(s, pos, tonumber(angle) or 0)
      ffi.C.lj_tld_shapehelper_step(s, 0, -size.y / 2)
      ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, size.y / 2)
      ffi.C.lj_tld_shapehelper_step(s, size.x / 2, size.y / 2)
      if thickness == true then thickness = s.defaultThickness end
      return thickness and s:stroke(true, color, thickness) or s:fill(color)
    end,

    ---Quickly add a triangle. If `thickness` is `false` or not set, triangle will be filled.
    ---@param pos vec3 @Triangle position.
    ---@param size vec2 @Triangle size in meters.
    ---@param angle number? @Triangle orientation. Default value: 0.
    ---@param thickness boolean|number? @Pass `true` to use `.defaultThickness`. Default value: `false` (filled triangle).
    ---@param color rgbm? @Color. Default value: `rgbm.colors.white`.
    ---@param shape1 number? @First shape modifier, from 0 to 1. Default value: `0.5`.
    ---@param shape2 number? @Second shape modifier, from 0 to 1. Default value: `0.5`.
    ---@return self
    arrow = function (s, pos, size, angle, thickness, color, shape1, shape2)
      shape1 = tonumber(shape1) or 0.5
      shape2 = tonumber(shape2) or 0.5
      if shape1 >= 0.99 then
        return s:triangle(pos, size, angle, thickness, color)
      elseif shape1 <= 0.01 then
        return s:rect(pos, size * vec2(shape2, 1), angle, thickness, color)
      end
      ffi.C.lj_tld_shapehelper(s, pos, tonumber(angle) or 0)
      shape1 = size.y * math.lerp(-1, 1, shape1) * 0.5
      shape2 = size.x * shape2 * 0.5
      ffi.C.lj_tld_shapehelper_step(s, -shape2, size.y / 2)
      ffi.C.lj_tld_shapehelper_step(s, shape2, size.y / 2)
      ffi.C.lj_tld_shapehelper_step(s, shape2, shape1)
      ffi.C.lj_tld_shapehelper_step(s, size.x / 2, shape1)
      ffi.C.lj_tld_shapehelper_step(s, 0, -size.y / 2)
      ffi.C.lj_tld_shapehelper_step(s, -size.x / 2, shape1)
      ffi.C.lj_tld_shapehelper_step(s, -shape2, shape1)
      if thickness == true then thickness = s.defaultThickness end
      return thickness and s:stroke(shape2 > 0.01, color, thickness) or s:fill(color)
    end,
  }
})

__definitions()

return function ()
  if not tld_data then
    tld_data = { i = {} }
  end
  local r = ffi.gc(ffi.C.lj_tld_init(), function (e) __util.native('lj_tld_dispose', e) end)
  table.insert(tld_data.i, r)
  return r
end