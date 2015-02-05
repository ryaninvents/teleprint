Bacon = require 'baconjs'
_ = require 'lodash'
uuid = require 'node-uuid'

# Ugh, Sylvester pollutes the global namespace
require 'sylvester'

# Constant to indicate that a dial's not touching.
NOT_TOUCHING = 'not_touching'

# Symbol to break state machine processing before we've run all the steps.
BREAK_EARLY = 'break_early'

# How far out from the center of the bed to touch-test.
RELATIVE_TOUCH_DISTANCE = 85/90

# Multiplied by the endstop offset before checking outcome. Search for ENDSTOP_OFFSET_MULTIPLIER
# in this file to see how it's used.
#
# TODO: remove from code; once I test this on my bot then I should be able to hardcode it
ENDSTOP_OFFSET_MULTIPLIER = 1

# Takes a two 2-element arrays and returns highest and lowest values found.
# Used in `reduce()` further on.
minMaxR = (a,b) -> [Math.min(a[0],b[0]), Math.max(a[1],b[1])]

# Takes a list of numbers and returns [min, max].
minMax = (list) -> list.map((n) -> [n,n]).reduce minMaxR

# ### Input events
#
# * `calibration:begin`: select the number of calibration points desired and kick off the calibration.
#   Currently only permits 7 points (center, near each of 3 towers, across from each of 3 towers)
# * `measurement:dial`: signifies that the user has entered in a dial measurement.
#   Parameters:
#   * `request`: the uuid of the measurement request.
#   * `dial`: either the string "not_touching" or an object with the following properties:
#     * `unit`: "in" or "mm".
#     * `qty`: the number attached to the measurement.
#
# ### Output events
#
# * `request:measurement`: request a measurement. This
#   will trigger the printer to move to the given point and prompt the user
#   for dial input.
# * `set:endstops`: send endstop values to the printer
# * `set:params`: send calibration parameters to the printer
# * `calibration:complete`: indicates that printer calibration is complete. The attached
#   object will contain the calibration parameters.

# **Arguments:**
#
# * `inputStream`: A stream of input events.
# * `bot`: A DeltaBot.
module.exports = (inputStream, bot) ->
  inputStream.withStateMachine {}, (state, event) ->
    events = []
    state = _.clone state
    newState = try
      (->
        # Convert the given measurement (object w/ unit and qty) into a number representing mm.
        to_mm = (msrmt) ->
          if msrmt.unit is 'in'
            msrmt.qty / 25.4
          else
            msrmt.qty

        # Handles the event that we've just received.
        handleNewEvent = ->
          # TODO: I'd like to eventually support a `calibration:abort` event. We can store the deltabot's
          # existing parameters on `calibration:begin` and restore them if we get a `calibration:abort`
          # event. -- RM 28 Jan 15
          switch event.type
            when 'calibration:begin'

              # **Start setting up our state machine.**
              event.startZ ?= 10
              state = {}
              state.epsilon = event.epsilon ? 1e-1

              # Keep track of our endstops.
              state.endstops = bot.towerLocations().map (tower, i) ->
                tower: i
                id: uuid.v4()
                x: tower.e(1)
                y: tower.e(2)
                z: event.startZ
                offset: bot.endstopOffsets[i]

              # Generate our touch points.
              if event.touchPoints isnt 7
                throw new Error 'Only supports 7 touch points for the time being'
              angles = [0...6].map (n) -> n*Math.PI/3
              state.plateTouches = angles.map (theta) ->
                x: bot.maxPrintRadius * RELATIVE_TOUCH_DISTANCE * Math.cos(theta)
                y: bot.maxPrintRadius * RELATIVE_TOUCH_DISTANCE * Math.sin(theta)
                z: event.startZ
              state.plateTouches.unshift
                x: 0
                y: 0
                z: event.startZ

            when 'measurement:dial'
              measurements = state.endstops.concat state.plateTouches
              measurement = _.findWhere(measurements, id:event.id)
              unless measurement?
                throw new Error "No measurement with id #{event.id} found"
              if event.dial is NOT_TOUCHING
                measurement.z--
                # TODO: this code is duped a couple times, break it into a func
                events.push
                  type: 'request:measurement'
                  id: measurement.id
                  point: measurement
                return BREAK_EARLY
              measurement.dial = event.dial

        # Check if we need endstop data, and if so, go get it.
        needEndstopData = ->

          # An endstop is considered to not have dial data if it is missing either unit or quantity.
          withoutDialData = (endstop) -> not (endstop.dial?.unit? and endstop.dial?.qty?)

          # We don't need endstop data, unless there's an endstop without dial data.
          return no unless _.any state.endstops, withoutDialData

          # Pick the first endstop with no dial data. (guaranteed to exist due to above check)
          endstop = state.endstops.filter(withoutDialData)[0]

          # Give it a new id.
          endstop.id = uuid.v4()

          # Let the user know that we need dial data for this one.
          events.push
            type: 'request:measurement'
            id: endstop.id
            point: endstop
          return yes

        # Test if endstop readings are within an acceptable range.
        endstopReadingsAreAcceptable = ->
          [min, max] = minMax state.endstops.map (endstop) -> to_mm(endstop.dial)
          return (max - min) <= state.epsilon

        # Update our offset guesses, upload them to the printer, and delete our dial data.
        invalidateEndstopData = ->
          sums = state.endstops.map (endstop) ->
            endstop.sum = endstop.z + to_mm(endstop.dial) + ENDSTOP_OFFSET_MULTIPLIER*endstop.offset
          [min, max] = minMax sums
          mid = (min + max) / 2
          endstops.forEach (endstop) ->
            endstop.offset += mid
            delete endstop.dial
          events.push
            type: 'set:endstops'
            endstops: state.endstops

        # Check if we need any plate touch data, and if so, go get it.
        needPlateTouchData = ->
          # A touch point is considered to not have dial data if it is missing either unit or quantity.
          withoutDialData = (touchPt) -> not (touchPt.dial?.unit? and touchPt.dial?.qty?)
          # We don't need touch point data, unless there's a touch point without dial data.
          return no unless _.any state.plateTouches, withoutDialData
          # Pick the first touch point with no dial data.
          touchPt = state.plateTouches.filter(withoutDialData)[0]
          # Give it a new id.
          touchPt.id = uuid.v4()
          # Let the user know that we need dial data for this one.
          events.push
            type: 'request:measurement'
            id: touchPt.id
            point: touchPt
          return yes

        # Test if plate touch readings are within an acceptable range.
        plateTouchReadingsAreAcceptable = ->
          [min, max] = minMax state.plateTouches.map (touchPt) -> to_mm(touchPt.dial)
          return (max - min) <= state.epsilon

        # Update our parameter guesses, upload them to the printer, and delete our dial data.
        invalidatePlateTouchData = ->
          isCenter = (t) -> t.x is 0 and t.y is 0
          center = state.plateTouches.filter(isCenter)[0]
          touches = state.plateTouches.reject(isCenter).map (touch) ->
            # TODO: verify that the error is `(touch.z + to_mm(touch.dial)) - (center.z + to_mm(center.dial))`
            # and not vice versa... or does it matter? -- RM 28 Jan 15
            [$V([touch.x, touch.y, touch.z]), (touch.z + to_mm(touch.dial)) - (center.z + to_mm(center.dial))]
          newBot = bot.solveGivenLocationsAndHeightErrors(touches)
          bot.armLength = newBot.armLength
          bot.bedRadius = newBot.bedRadius
          state.plateTouches.forEach (touch) ->
            delete touch.dial
          events.push
            type: 'set:params'
            params:
              armLength: newBot.armLength
              bedRadius: newBot.bedRadius

        # Finish the calibration sequence.
        finishCalibration = ->
          events.push
            type: 'calibration:complete'

        # Here's the part of this function that's actually readable, and the
        # goal of all of the above.
        if handleNewEvent() is BREAK_EARLY then return state
        if needEndstopData()
          return state
        unless endstopReadingsAreAcceptable()
          invalidateEndstopData()
          needEndstopData()
          return state
        if needPlateTouchData()
          return state
        unless plateTouchReadingsAreAcceptable()
          invalidatePlateTouchData()
          needPlateTouchData()
          return state
        finishCalibration()
        return state
      )()
    catch e
      events = [Bacon.Error e]
      state
    [newState, events]
