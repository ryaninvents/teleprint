module.exports =
  # Position.
  x: 0
  y: 0
  z: 0
  e: 0
  # Feedrate for travel and extrusion.
  rapidMoveRate:      1000
  controlledMoveRate: 1000
  # Temperatures of nozzle and heated bed.
  nozzleTemp: 20
  bedTemp: 20
  # Check whether we've homed since the last reset.
  homed:
    x: no
    y: no
    z: no
  # Units of measurement.
  units: 'mm'
  # `absolute` or `relative` positioning
  positioning: 'absolute'
  # Which motors are powered on?
  motorPower:
    x: yes
    y: yes
    z: yes
    e: yes
  stepsPerUnit: 20
  # Goal temperatures to reach.
  targetNozzleTemp: 20
  targetBedTemp: 20
  # Endstop statuses.
  endstops:
    x:
      min: on
      max: on
    y:
      min: on
      max: on
    z:
      min: on
      max: on
  # Delta calibration
  deltaParams:
    diagonalRod: 250
    deltaRadius: 160
    segmentsPerSecond: 200
