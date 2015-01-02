# # State Transform
#
# Describes how to take gcode input and transform the state
# of a machine. Emits events appropriately that get transformed
# into fake "serial" output.
Bacon = require 'baconjs'
_ = require 'lodash'

# "No-op" for commands that won't affect our state.
noop = -> ['ok']

# ## Actions
#
# Hash containing all the actions that our sim printer supports.
# The functions are looked up by the first word in the gcode line,
# which is stripped before getting passed in here.
#
# Each of these functions accepts a single array of strings as
# its argument. This array represents the remaining words in the line.
# Comments and checksum are removed before we get here.
#
# The current state of the machine is stored as "this" (or `@` in
# CoffeeScript). This is a clone of the original object and so may
# be freely mutated.
#
# Each function returns an array that may contain strings and/or
# `Bacon.Error`s. The strings will be handled as though they were
# lines of serial output; the errors will be passed back through
# the stream and handled accordingly.
actions =
  # G0: Rapid move.
  G0: (args) ->
    events = ['ok']
    args.forEach (arg) =>
      arg = arg.match /^([A-Z])(-?[.\d]+)$/
      return unless arg?
      [arg, axis, pos] = arg
      unless @[axis]?
        events.push new Bacon.Error "Unknown axis #{axis}"
        return
      pos = if @units is 'in'
        Number(pos)/25.4
      else
        Number(pos)
      if (@positioning is 'absolute') and @[axis]?
        @[axis] = pos
      else
        @[axis] += pos
    events

  # G1: Controlled move.
  G1: -> actions.G0.apply @, arguments

  # G2: Clockwise arc movement.
  G2: -> actions.G0.apply @, arguments
  # G3: Counterclockwise arc movement.
  G3: -> actions.G0.apply @, arguments

  # G28: Home the machine.
  G28: ->
    @X = @Y = @Z = 0.0
    @homed.X = @homed.Y = @homed.Z = yes
    ['ok']
  # G4: Dwell.
  G4: noop
  # G20: Set units to inches.
  G20: -> @units = 'in'; ['ok']
  # G21: Set units to mm.
  G21: -> @units = 'mm'; ['ok']
  # G90: Use absolute positioning.
  G90: -> @positioning = 'absolute'; ['ok']
  # G91: Use relative positioning.
  G91: -> @positioning = 'relative'; ['ok']
  # G92: Set zero position.
  G92: noop
  # M0: Stop the machine and shut it off.
  M0: -> actions.M18.apply @, arguments
  # M1: Put the machine to sleep.
  M1: -> actions.M18.apply @, arguments
  # M17: Enable all steppers.
  M17: ->
    @motorPower.X = on
    @motorPower.Y = on
    @motorPower.Z = on
    @motorPower.E = on
    ['ok']
  # M18: Disable all steppers.
  M18: ->
    @motorPower.X = off
    @motorPower.Y = off
    @motorPower.Z = off
    @motorPower.E = off
    ['ok']
  # M92: Set axis steps per unit (mm or in).
  M92: (args) ->
    # TODO: error message here
    unless args.length
      return ['ok']
    steps = args[0].match /^[A-Z]([.\d]+)$/
    unless steps?
      return [new Bacon.Error "M92 requires axis and steps per unit"]
    [x, @stepsPerUnit] = steps.map Number
    ['ok']
  # M104: Set extruder temp.
  #
  # TODO: simulate "getting up to temp" so we can draw graphs
  M104: (args) ->
    unless args.length
      # TODO: error message here
      return ['ok']
    temp = args[0].match /^S([.\d]+)$/
    unless temp?
      return [new Bacon.Error "M104 requires extruder temp as S##"]
    @nozzleTemp = @targetNozzleTemp = Number(temp[1])
    ['ok']
  # M105: Get current extruder temp.
  M105: (args) ->
    ["ok T:#{@nozzleTemp} B:#{@bedTemp}"]
  # M109: Set extruder temp and wait to get up to temp.
  #
  # Not sure how to handle this in the current implementation...
  M109: (args) -> actions.M104.apply @, arguments
  # M110: Set line number.
  M110: (args) ->
    unless args.length
      # TODO: error message here
      return ['ok']
    line = args[0].match /^N(\d+)$/
    unless line? and (Number(line[1]) > 0)
      return [new Bacon.Error "M110 requires line # as N##"]
    @lineNumber = Number line[1]
    ['ok']
  # M111: Set debug level.
  M111: noop
  # M112: E-stop.
  M112: -> actions.M18.apply @, arguments
  # M114: Get current position.
  M114: ->
    ["ok X:#{@X} Y:#{@Y} Z:#{@Z} E:#{@E}"]
  # M115: Get firmware version and capabilities.
  M115: ->
    ["ok FIRMWARE_NAME:Teleprint_Simulator EXTRUDER_COUNT:1 " +
    "MACHINE_TYPE:Imaginary"]
  # M116: Wait for temperatures to arrive at desired values.
  M116: noop
  # M119: Get status of endstops.
  M119: ->
    message = "ok " + (_.flatten ['X','Y','Z'].map (axis) =>
      ['min','max'].map (end) =>
        status = if @endstops[axis][end]
          'CLOSED'
        else
          'OPEN'
        "#{axis}_#{end.toUpperCase()}:#{status}"
    ).join ' '
    [message]
  # M140: Set bed temperature and return immediately.
  M140: (args) ->
    # TODO: error message here
    unless args.length
      return ['ok']
    temp = args[0].match /^S([.\d]+)$/
    unless temp?
      return [new Bacon.Error "M140 requires bed temp as S##"]
    temp = Number(temp[1])
    @bedTemp = @targetBedTemp = temp
    ['ok']
  # M190: Wait for bed to reach target temp.
  M190: noop
  # M300: Play beep sound. _boop_
  M300: noop
  # M665: Set delta configuration.
  #
  # **L:** diagonal rod length; **R:** delta radius;
  # **S:** segments per second.
  M665: (args) ->
    paramMappings =
      L: 'diagonalRod'
      R: 'deltaRadius'
      S: 'segmentsPerSecond'
    events = ['ok']
    args.forEach (a) =>
      arg = a.match /^([A-Z])([.\d]+)$/
      unless arg?
        events.push new Bacon.Error "M665: Couldn't read param #{a}"
        return
      [arg, param, value] = arg
      unless paramMappings[param]?
        events.push new Bacon.Error "M665: Unknown delta param #{param}"
        return
      @deltaParams[paramMappings[param]] = Number(value)
    events
  # M666: Adjust delta endstops. X, Y, Z here refer to towers
  # and not Cartesian axes.
  M666: (args) ->
    events = ['ok']
    args.forEach (a) =>
      arg = a.match /^([X-Z])([+-]?[.\d]+)$/
      unless arg?
        events.push new Bacon.Error "M666: Couldn't read param #{a}"
        return
      [arg, axis, value] = arg
      @deltaParams.endstopOffsets[axis] = Number(value)
    events


# This function is suitable for use in Bacon's `.withStateMachine`
# method.
module.exports = (state, gcode) ->
  state = _.clone state
  # Remove comments.
  gcode = gcode.value().trim().split(';')[0]
  # TODO: line number/checksum checking.
  # For now, we're stripping and ignoring checksum stuff.
  gcodeChecksum = gcode.trim().match /^N(\d+)\s+(.*)\s*\*(\d+)$/
  if gcodeChecksum
    [line, gcode, checksum] = gcodeChecksum
  # Split on spaces.
  gcode = gcode.toUpperCase().split /\s+/
  # Pull out the action and arguments.
  action = gcode[0]
  args = gcode[1..-1]
  # Have we implemented the desired action?
  if actions[action]?
    try
      events = actions[action].call state, args
    catch e
      events = [new Bacon.Error e.toString()]
      console.error e
      console.error e.stack
    events = events.filter(_.identity).map (e) ->
      if e.isError?() or e.isEnd?() or e.isNext?()
        e
      else
        new Bacon.Next(e)
    [state, events]
  else
    [state, [Bacon.Error "Unrecognized action #{action}"]]
