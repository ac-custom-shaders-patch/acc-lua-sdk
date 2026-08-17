__source 'lua/api_physics.cpp'
__source 'lua/api_physics_shared.cpp'
__source 'lua/api_physics_raycast.cpp'
__namespace 'physics'

require './ac_ray'

ffi.cdef [[ typedef struct __declspec(align(4)) { 
  const bool gearUp; 
  const bool gearDown; 
  const bool drs; 
  const bool kers; 
  const bool brakeBalanceUp; 
  const bool brakeBalanceDown; 
  const int requestedGearIndex; 
  const bool isShifterSupported; 
  const float handbrake; 
  const bool absUp; 
  const bool absDown; 
  const bool tcUp; 
  const bool tcDown; 
  const bool turboUp; 
  const bool turboDown; 
  const bool engineBrakeUp; 
  const bool engineBrakeDown; 
  const bool mgukDeliveryUp; 
  const bool mgukDeliveryDown; 
  const bool mgukRecoveryUp; 
  const bool mgukRecoveryDown; 
  const uint8_t mguhMode; 
  const float gas; 
  const float brake; 
  const float steer; 
  const float clutch; 
} ac_car_controls; ]]

__util.lazymod('lib_physics', physics, {
  'RigidBody',
  'addTrackSurface'
})
