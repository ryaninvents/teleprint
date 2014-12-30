module.exports =
  # Position.
  X: 0
  Y: 0
  Z: 0
  E: 0
  # Feedrate for travel and extrusion.
  F: 1000
  # Temperatures of nozzle and heated bed.
  nozzleTemp: 20
  bedTemp: 20
  # Check whether we've homed since the last reset.
  homed:
    X: no
    Y: no
    Z: no
  # Units of measurement.
  units: 'mm'
  # `absolute` or `relative` positioning
  positioning: 'absolute'
  # Which motors are powered on?
  motorPower:
    X: off
    Y: off
    Z: off
    E: off
  stepsPerUnit: 20
  # Goal temperatures to reach.
  targetNozzleTemp: 20
  targetBedTemp: 20
  # Endstop statuses.
  endstops:
    X:
      min: on
      max: off
    Y:
      min: on
      max: off
    Z:
      min: on
      max: off
  # Delta calibration
  deltaParams:
    diagonalRod: 250
    deltaRadius: 160
    segmentsPerSecond: 200
    endstopOffsets:
      X: 0
      Y: 0
      Z: 0
  # Line number, to make sure we're not skipping code
  lineNumber: 0
