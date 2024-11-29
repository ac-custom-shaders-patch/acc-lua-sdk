-- ac.TyreParameterID = __enum({ cpp = 'tyre_parameter_id' }, {
--   RollingResistanceSlip = 0
-- })

ac.CarPhysicsValueID = __enum({ cpp = 'car_physics_value_id' }, {
  ERSRecovery = 0, ---Value from 0 to 1
  ERSHeatCharging = 1, ---`true` or `false`
  AWD2MaxTorque = 2, ---Won’t work if there is an AWD2 controller present
})
