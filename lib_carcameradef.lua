__source 'lua/api_car_control_cameras.cpp'

ffi.cdef [[ 
typedef struct {
  mat4x4 transform;
  float fov;
  float exposure;
  bool externalSound;
  uint8_t __carIndex;
  uint8_t __cameraIndex;
} carcameradef;
]]

---Stores parameters for a car camera (enabled with F6).
---@class ac.CarCameraParams
---@field transform mat4x4 @Transformation relative to car model. Note: due to some techical reasons direction `.look` is facing backwards.
---@field fov number @Field of view angle in degrees, automatically guessed value: 10.
---@field exposure number @Exposure.
---@field externalSound boolean @Should internal or external audio be used.
---@field index integer @Read-only field with camera index for reference.
---@field carIndex integer @Read-only field with car index for reference.
---@field clipNear number? @Near clip distance in meters. If `nil`, automatically computed value (depends on graphics settings) is used. Being an extension on top of original AC, might be slower to access than other fields. If you want to add a field to “cameras.ini”, use `__EXT_CLIP_NEAR` key. Altering this value might lead CSP to alter far clip value as well.
ffi.metatype('carcameradef', { 
  __index = function (self, k) 
    if k == 'index' then return self.__cameraIndex end
    if k == 'clipNear' then return __util.native('carcameradef_clipnear', self.__carIndex, self.__cameraIndex) end
    return nil
  end,
  __newindex = function (self, k, v) 
    if k == 'clipNear' then __util.native('carcameradef_clipnear', self.__carIndex, self.__cameraIndex, tonumber(v) or 0) end
  end,
})

__definitions()

function ac.accessCarCamera(cameraIndex)
  local r = ffi.C.lj_accessCarCamera_inner(tonumber(cameraIndex) or 0)
	return r ~= nil and r or nil
end

return ac.accessCarCamera