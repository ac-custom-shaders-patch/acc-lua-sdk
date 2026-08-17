-- ac.TyreParameterID = __enum({ cpp = 'tyre_parameter_id' }, {
--   RollingResistanceSlip = 0
-- })

ac.CarPhysicsValueID = __enum({ cpp = 'car_physics_value_id' }, {
  ERSRecovery = 0, ---Value from 0 to 1
  ERSHeatCharging = 1, ---`true` or `false`
  AWD2MaxTorque = 2, ---Won’t work if there is an AWD2 controller present
  FFBMult = 3, ---`CONTROLS/FFMULT` from “car.ini”
  SteerAssist = 4, ---`CONTROLS/STEER_ASSIST` from “car.ini”
  SteerRatio = 5, ---`CONTROLS/STEER_RATIO` from “car.ini”. Added in 0.3.0-preview366.
  LinearSteerRodRatio = 6, ---`CONTROLS/LINEAR_STEER_ROD_RATIO` from “car.ini”. Added in 0.3.0-preview366.
  DrivetrainOpenThreshold = 10, ---Threshold from 0 to 1. If ratio of gearbox input velocity to engine velocity is equals or below this value, AC considers engine and gearbox input locked. Set to 0 to disable locking. Added in 0.3.0-preview151. Default value: 0.1.
  DrivetrainClutchOverride = 11, ---Override clutch value computed by drivetrain at the start. By default, it’s the input clutch value raised to 1.5 power. Set to a negative value to disable the override. Added in 0.3.0-preview151.
  DrivetrainDriveVelocityMult = 12, ---Use this value to pass a multiplier for drivetrain velocity, for something like P gear of an automated gearbox. Added in 0.3.0-preview151.
  DrivetrainEngagedGear = 13, ---This value allows to override current gear directly without any checks. Use very carefully. Added in 0.3.0-preview202.
  EngineLimiterCycles = 14, ---Number of steps for engine limiter to be active for. Set to 0 to disable limiter, or to, for example, 2, to cut off throttle for the next two frames.
  BrakeTorque = 101, ---Maximum brake torque. Added in 0.3.0-preview398.
  HandbrakeTorque = 102, ---Maximum handbrake torque. Added in 0.3.0-preview398.
  BrakeFrontBias = 103, ---Front brakes bias. Added in 0.3.0-preview398.
  OriginalTCPresent = 2001, ---Pass `false` to stop the original AC traction control entirely
  TCEnabled = 2002, ---Pass `true` or `false` to specify if TC is enabled or not (not active!). If original TC is present, won’t have an effect, as the value would be overriden, so maybe set `.OriginalTCPresent` to `false` first.
  TCThrottleOverride = 2003, ---Pass a number that will act as a throttle pedal multiplier. Automatically marks TC as enabled (as if `.TCEnabled` has been set to `true`) if value is different from 1. If original TC is present, won’t have an effect, as the value would be overriden, so maybe set `.OriginalTCPresent` to `false` first.
  ForcedAutoclutch = 2004, ---Pass `true` to force auto-clutch on, or `false` to fully disable it. Added in 0.3.0-preview148. For this thing to work reliably, it might be a good idea to call it every frame, otherwise some other components might re-enable it.
  BlockOriginalTC = 2005, ---Pass `true` to stop original TC implementation while leaving `.OriginalTCPresent` present flag and such as-is.
  AutoShifterUp = 2010, ---`AUTO_SHIFTER/UP`
  AutoShifterDown = 2011, ---`AUTO_SHIFTER/DOWN`
  AutoShifterSlipThreshold = 2012, ---`AUTO_SHIFTER/SLIP_THRESHOLD`
  AutoShifterGasCutoffTime = 2013, ---`AUTO_SHIFTER/GAS_CUTOFF_TIME`
  ForcelessTyres = 10001, ---`true` or `false`. If forceless, tyre is pretty much non-existent, but rim-ground collisions can still occur. Uses `tyres` param.
  TyresVirtualKm = 10002, ---Override driven distance (used for wear calculation).
  TyresDirtLevel = 10003, ---Override dirt level.
  TyresFlatSpot = 10004, ---Override flat spot.
  TyresSlipRatio = 10005, ---Override slip ratio.
})
