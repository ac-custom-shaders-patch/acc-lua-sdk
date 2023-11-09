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

local _rpsActive = {}
ffi.cdef [[ 
typedef struct {
  void* _frame;
} replayextension;
]]

---Create a new stream for recording data to replays. Write data in returned structure if not in replay mode, read data if in replay mode (use `sim.isReplayActive` to check if you need to write or read the data).
---Few important points:
--- - Each frame should not exceed 256 bytes to keep replay size appropriate.
--- - While data will be interpolated between frames during reading, directional vectors won’t be re-normalized. 
--- - If two different apps would open a stream with the same layout, they’ll share a replay entry.
--- - Each opened replay stream will persist through the entire AC session to be saved at the end. Currently, the limit is 128 streams per session.
--- - Default values for unitialized frames are zeroes.
---@generic T
---@param layout T @A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Unlike other similar functions, here you shouldn’t use string, otherwise data blending won’t work.
---@param callback fun()? @Callback that will be called when replay stops. Use this callback to re-apply data from structure: at the moment of the call it will contain stuff from last recorded frame allowing you to restore the state of a simulation to when replay mode was activated.
---@return T? @Might return `nil` if there is game is launched in replay mode and there is no such data stored in the replay.
function ac.ReplayStream(layout, callback)
  local layoutStr, reordered = ac.StructItem.__build(layout)
  if type(layoutStr) ~= 'string' then error('Layout is required and should be a table or a string', 2) end

  local name = '__rps_'..tostring(ac.checksumXXH(layoutStr))
  local ret = _rpsActive[name]
  if ret == nil then
    ffi.cdef(ac.StructItem.__cdef(name, layoutStr, true))
    local size = ffi.sizeof(name)
    ret = ffi.gc(ffi.C.lj_replayextension_new(name, size, ac.StructItem.__replayMixing(reordered), __util.setCallback(callback)), ffi.C.lj_replayextension_gc)
    _rpsActive[name] = ret
  end
  if ret._frame == nil then
    return nil
  end
  return ffi.cast(name..'*', ret._frame)
end