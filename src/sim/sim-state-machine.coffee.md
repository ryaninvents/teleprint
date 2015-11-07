# State Transform

Describes how to take gcode input and transform the state of a machine.
Emits events appropriately that get transformed into fake "serial"
output.

**Note:** at the moment, the simulator sends an `ok` after an error to return control to the PC. I'm not sure if this is correct, but it'll take a little bit of research to find out.

No-op for commands that won't affect state.

    noop = (send) -> -> send 'ok'

## Commands

Hash containing all the commands that our sim printer supports. The functions are looked up by the first word in the gcode line, which gets stripped before being passed in.

These functions are curried: the first application supplies two functions, `send` and `error`, that are callbacks to generate an event and an error respectively. The second application is with the strings representing the words in the line of gcode, minus the command identifier and any comments or checksum.

    module.exports = actions =

### G0: Rapid move

Parameters:
* **Xnnn** Position to move on the X axis
* **Ynnn** Position to move on the Y axis
* **Znnn** Position to move on the Z axis
* **Ennn** Amount to extrude between the starting and ending point
* **Fnnn** Feedrate per minute of the move
* **Snnn** Flag: check if endstop was hit? (not simulated)
  * **S0** to ignore endstops
  * **S1** to check endstops
  * **S2** special case, varies based on printer

"Rapid" is effectively "instant" because right now we can't simulate the passage of time.

      G0: (send, error) -> (args...) ->
        args.forEach (arg) =>

          # Match single letter (axis), optional minus, and a series of
          # digits or points.
          arg = arg.match /^([A-Z])(-?[.\d]+)$/
          # Bail if no match.
          return unless arg?

          [arg, axis, pos] = arg

          # Handle feedrate specially.
          if axis === 'F'
            @feedrate = pos
            return

          unless @[axis]?
            return error "Unknown axis #{axis}"

          pos = if @units is 'in'
            Number(pos) / 25.4
          else
            Number(pos)

          if (@positioning is 'absolute') and @[axis]?
            @[axis] = pos
          else
            @[axis] += pos

        send 'ok'

### G1: Controlled move

For simulation purposes, `G0` and `G1` are the same.

      G1: -> actions.G0.apply @, arguments

### G2: Clockwise arc movement

      G2: -> actions.G0.apply @, arguments

### G3: Counterclockwise arc movement

      G3: -> actions.G0.apply @, arguments

### G4: Dwell

      G4: noop

### G20: Set units to inches

      G20: (send) -> ->
        @units = 'in'
        send 'ok'

### G21: Set units to millimeters

      G21: (send) -> ->
        @units = 'mm'
        send 'ok'

### G28: Home the machine

      G28: (send) -> ->
        @X = @Y = @Z = 0.0
        @homed.X = @homed.Y = @homed.Z = yes
        send 'ok'

### G90: Use absolute positioning

      G90: (send) -> ->
        @positioning = 'absolute'
        send 'ok'

### G91: Use relative positioning

      G91: (send) -> ->
        @positioning = 'relative'
        send 'ok'

### G92: Set zero position

      G92: noop

### M0: Stop machine and shut down

Simulating by shutting off all motors.

      M0: actions.M18.apply @, arguments

### M1: Put the machine to sleep

Simulating by shutting off all motors.

      M1: actions.M18.apply @, arguments

### M17: Enable all steppers

      M17: (send) -> ->
        @motorPower.X = on
        @motorPower.Y = on
        @motorPower.Z = on
        @motorPower.E = on
        send 'ok'

### M18: Disable all steppers

      M18: (send) -> ->
        @motorPower.X = off
        @motorPower.Y = off
        @motorPower.Z = off
        @motorPower.E = off
        send 'ok'

### M92: Set axis steps per unit

Steps per unit depends on the unit currently set (mm or in).

Example: If the current unit is millimeter, `M92 X30` would set the X-axis to 30 steps per millimeter.

      M92: noop

### M104: Set extruder temp

This is deprecated, but I haven't found documentation on what's supplanting it, so until then this command stays.

      M104: (send, error) -> (arg) ->
        unless arg?
          error 'No args passed to M104'
          return send 'ok'
        temp = arg.match /^S([.\d]+)$/
        unless temp?
          error "M104 requires extruder temp as Snn"
          return send 'ok'
        @nozzleTemp = @targetNozzleTemp = Number(temp[1])
        send 'ok'

### M105: Get current extruder temp

      M105: (send) -> -> send "ok T:#{@nozzleTemp} B:#{@bedTemp}"

### M109: Set extruder temp and wait

Not sure how to implement this for the time being, so we'll just proxy `M104`.

      M109: actions.M104.apply @, arguments

### M110: Set line number

      M110: (send, error) -> (arg) ->
        unless arg?
          error "Must supply argument to M110"
          return send 'ok'
        line = arg.match /^N(\d+)$/
        unless line? and (Number(line[1]) > 0)
          error "M110 requires line number as Nnnn"
          return send 'ok'
        [nil, @lineNumber] = line
        send 'ok'

### M111: Set debug level

      M111: noop

### M112: Emergency stop

      M112: -> actions.M18.apply @, arguments

### M114: Get current position

      M114: (send) -> -> send "ok X:#{@X} Y:#{@Y} Z:#{@Z} E:#{@E}"

### M115: Firmware version and capabilities

      M115: (send) -> ->
        send "ok FIRMWARE_NAME:Teleprint_Simulator EXTRUDER_COUNT:1 MACHINE_TYPE:Simulated"

### M116: Wait for temperatures to reach targets

      M116: noop

### M119: Get status of endstops

      M119: (send) -> ->
        stops =
          X:
            min: @X <= @config.volume.X.min
            max: @X >= @config.volume.X.max
          Y:
            min: @Y <= @config.volume.Y.min
            max: @Y >= @config.volume.Y.max
          Z:
            min: @Z <= @config.volume.Z.min
            max: @Z >= @config.volume.Z.max
        send "ok " + Object.keys(stops).map((axis) =>
          ['min','max'].map((end) =>
            status = if stops[axis][end] then 'CLOSED' else 'OPEN'
            "#{axis}_#{end.toUpperCase()}:#{status}"
          ).join ' '
        ).join ' '

### M140: Set bed temperature and return immediately

      M140: (send, error) -> (arg) ->
        unless arg?
          error "M140 requires bed temp"
          return send 'ok'
        temp = arg.match /^S([.\d]+)$/
        unless temp?
          error "M140 requires bed temp as Snn"
          return send 'ok'
        temp = Number(temp[1])
        @bedTemp = @targetBedTemp = temp
        send 'ok'

### M190: Wait for bed to reach target temp

      M190: noop

### M300: Play beep sound

      M300: noop

### M665: Set delta configuration

Ordinarily I'd ignore this in the simulation, but I'm building a deltabot of my own and I want to simulate it for calibration purposes, so here we go.

      M665: (send, error) -> (args...) ->
        unless @deltaParams?
          error "M665: This machine is not a delta; cannot set delta params"
          return send 'ok'
        paramMappings =
          L: 'diagonalRod'
          R: 'deltaRadius'
          S: 'segmentsPerSecond'
        args.forEach (a) =>
          arg = a.match /^([A-Z])([.\d]+)$/
          unless arg?
            return error "M665: Couldn't read param #{a}"
          [arg, param, value] = arg
          unless paramMappings[param]?
            return error "M665: Unknown delta param '#{param}'"
          @deltaParams[paramMappings[param]] = Number(value)
        send 'ok'

### M666: Adjust delta endstops

`X`, `Y`, and `Z` here refer to delta towers, not Cartesian axes.

      M666: (send, error) -> (args...) ->
        unless @deltaParams?
          error "M666: This machine is not a delta; cannot set delta params"
          return send 'ok'
        args.forEach (a) =>
          arg = a.match /^([X-Z])([+-]?[.\d]+)$/
          unless arg?
            error "M666: Could not read param #{a}"
          [arg, axis, value] = arg
          @deltaParams.endstopOffsets[axis] = Number(value)
        send 'ok'
