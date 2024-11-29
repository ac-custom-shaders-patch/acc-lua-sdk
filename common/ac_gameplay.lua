__source 'lua/api_gameplay.cpp'
__source 'lua/api_replay_extension.cpp'
__allow 'gp'
__namespace 'ui'

ffi.cdef [[ 
typedef struct {
  mat4x4 transform;
  const mat4x4 transformOriginal;
  float fov;
  const float fovOriginal;
  float dofDistance;
  const float dofDistanceOriginal;
  float dofFactor;
  const float dofFactorOriginal;
  float exposure;
  const float exposureOriginal;
  float clipNear;
  const float clipNearOriginal;
  float clipFar;
  const float clipFarOriginal;
  float lodMultiplier;
  const float lodMultiplierOriginal;
  vec3 listenerVelocity;
  float ownShare;
  float cameraRestoreThreshold;
} grabbedcamera;
]]

---Tries to grabs camera for script to control it. If successfull, returns instance of `ac.GrabbedCamera` which you can then use to
---move camera, rotate it and alter some of its properties like DOF, FOV or exposure. However, if any other scripts are
---controlling camera currently, returns `nil` and a detailed error message with the name of script currently holding camera (with
---the reason to do so if provided) as a second argument.
---@param reason string|nil @Optional comment for the reason for grabbing camera, to simplify possible conflicts resolution.
---@return ac.GrabbedCamera|nil
---@return nil|string
function ac.grabCamera(reason)
  local r = ffi.C.lj_grabbedcamera_new__gp(reason ~= nil and tostring(reason) or nil)
  if r == nil then return nil, __util.strrefp(ffi.C.lj_grabbedcamera_lasterror__gp()) end
  return ffi.gc(r, ffi.C.lj_grabbedcamera_gc__gp), nil
end

---Camera holder, for scripts to move camera in their own custom way. Obtained by calling `ac.grabCamera()`. When script is done with
---its camera movement, call `:dispose()` to release camera back to Assetto Corsa. If any reference to an instance of active holder
---is lost and `ac.GrabbedCamera` gets garbage collected, camera is also released.
---
---To move camera, access `.transform` property and edit it directly, setting new camera position and orientation vectors. Note:
---although matrix gives you access to `.side` and `.up` vectors, you don’t have to set them explicitly: before applying, matrix
---gets normalized automatically to make sure camera would not end up with a broken matrix.
---
---If you want to transition camera smoothly, use `.ownShare` property. It defaults to 1, but if set to 0.5, for example,
---resulting camera position would be in the middle of camera position set by AC and camera position set by script. If below 1,
---AC would also update camera position based on its current mode, once `.ownShare` reaches 1, CSP would switch current camera mode
---to free camera (switching back to original camera mode once `.ownShare` gets smaller).
---@class ac.GrabbedCamera
---@field transform mat4x4 @Camera transformation which will be applied with the next frame.
---@field transformOriginal mat4x4 @Camera transformation from original AC camera behaviour. Use `.ownShare` to smoothly transition between two, or access it here directly.
---@field fov number @Vertical FOV to be applied next frame, in degrees. Note: it would not affect camera in VR mode.
---@field fovOriginal number @Original camera vertical FOV, in degrees.
---@field dofDistance number @DOF distance to be applied next frame, in meters. Has an effect if `.dofFactor` is above 0. Requires YEBIS to work.
---@field dofDistanceOriginal number @Original camera DOF distance, in degrees.
---@field dofFactor number @DOF factor to be applied next frame. To get DOF to work, set it to 1.
---@field dofFactorOriginal number @Original camera DOF factor.
---@field exposure number @Camera exposure to be applied next frame.
---@field exposureOriginal number @Original camera exposure.
---@field listenerVelocity vec3 @Use this value to change listener velocity used by FMOD.
---@field ownShare number @Value for mixing original and custom camera parameters. Default value: 1. If 0, camera is controlled by Assetto Corsa. If 1, parameters set in `ac.GrabbedCamera` are used. If 0.5, parameters are mixed evenly.
---@field cameraRestoreThreshold number @Camera switches to original mode (for rendering logic) once `ownShare` drops below this value.
ffi.metatype('grabbedcamera', { __index = {
  ---Returns `true` if camera holder is currently holding camera and was not disposed.
  ---@return boolean
  active = ffi.C.lj_grabbedcamera_active__gp,
  ---Releases held camera and allows Assetto Corsa to control camera as usual.
  dispose = ffi.C.lj_grabbedcamera_dispose__gp,
  ---Normalizes camera matrix (makes sure all direction vectors are orthogonal and have proper length). No need to call it explicitly:
  ---camera matrix would undergo normalization before applying anyway. But it could be helpful if you need to access normalized `.side`,
  ---for example, right after altering `.look`.
  normalize = ffi.C.lj_grabbedcamera_normalize__gp,
  ---Align a certain car in a viewport in a way similar to CM Showroom Preview generation. Returns a vector with camera offset.
  ---@param carIndex integer
  ---@param xAlign boolean
  ---@param xOffset number
  ---@param xOffsetRelative boolean
  ---@param yAlign boolean
  ---@param yOffset number
  ---@param yOffsetRelative boolean
  ---@return vec3
  alignCar = function (s, carIndex, xAlign, xOffset, xOffsetRelative, yAlign, yOffset, yOffsetRelative)
    return ffi.C.lj_grabbedcamera_aligncar__gp(s, tonumber(carIndex) or 0,
      xAlign ~= false, tonumber(xOffset) or 0, xOffsetRelative ~= false, 
      yAlign ~= false, tonumber(yOffset) or 0, yOffsetRelative ~= false)
  end,
} })

---Sets a callback which will be called when drawing driver tooltip card. Within, `ui.` functions can be used to add additional information.
---@param overrideOriginal boolean? @Set to `true` to hide original UI. Use carefully, might create some compatibility issues. Default value: `false`.
---@param callback fun(carIndex: integer) @Callback which will be called each time tooltip is drawn, getting 0-based car index.
---@return ac.Disposable
function ui.onDriverTooltip(overrideOriginal, callback)
  if type(overrideOriginal) == 'function' then
    overrideOriginal, callback = false, overrideOriginal
  end
	callback = __util.setCallback(callback)
	return __util.disposable(ffi.C.lj_onDriverTooltip_inner__ui(not not overrideOriginal, callback))
end

---Sets a callback which will be called when drawing tooltip. If new driver tags are disabled, using this function
---forcefully activates them (since 0.2.4).
---@param overrideOriginal boolean? @Set to `true` to hide original elements. If you want to add something to original layout, please keep it mind it might be changed in the future, and used font can vary as well, so don’t rely on it too much. Default value: `false`.
---@param bgColor rgbm? @Optional background color tint.
---@param callback fun(car: ac.StateCar) @Callback which will be called each time tooltip is drawn, getting 0-based car index.
---@param tweaks {mainSize: number?, mirrorSize: number?, distanceMultiplier: number?, tagSize: vec2?}? @Optional setting tweaks overriding user settings (use only if necessary). Tag size is in pixels, by default it’s 512×64.
---@return ac.Disposable
function ui.onDriverNameTag(overrideOriginal, bgColor, callback, tweaks)
  if type(overrideOriginal) == 'function' then
    overrideOriginal, callback = false, overrideOriginal
  end
  if type(callback) ~= 'function' then
    callback = function () end
  end
  local bitSize = vec2(512, 64)
  local bitSizeOverride = tweaks and __util.ensure_vec2_nil(tweaks.tagSize)
  if bitSizeOverride then
    bitSize:set(bitSizeOverride)
  end
	local callbackWrapped = function ()
    local sim = ac.getSim()
    for _, c in ac.iterateCars() do
      if c.isActive and c.nodeIndex < 32 and not c.isHidingLabels then
        ui.setCursorX(0)
        ui.setCursorY(bitSize.y * c.nodeIndex)
        if ui.beginChild(tostring(_), bitSize, false, bit.bor(ui.WindowFlags.NoScrollbar, ui.WindowFlags.NoInputs, ui.WindowFlags.NoBackground)) then
          __util.pushEnsureToCall(ui.endChild)
          callback(c)
          __util.popEnsureToCall()
        end
      end 
    end
  end
  return __util.native('ui.onDriverNameTag', not not overrideOriginal, __util.ensure_rgbm_nil(bgColor), callbackWrapped,
    tweaks and tonumber(tweaks.mainSize) or math.huge, tweaks and tonumber(tweaks.mirrorSize) or math.huge, 
    tweaks and tonumber(tweaks.distanceMultiplier) or math.huge, tweaks and __util.ensure_vec2_nil(tweaks.tagSize))
end
