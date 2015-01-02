# # Sim Machine
#
# Represents a simulated 3D printer so you can test
# this software without having access to a real
# printer.
_ = require 'lodash'
Bacon = require 'baconjs'
Machine = require './machine'
Backbone = require 'backbone'
INITIAL_STATE = require './sim-default-state'
stateTransform = require './sim-state-transform'

module.exports =
SimMachine = Backbone.Model.extend
  initialize: () ->

    # All moves are instantaneous. Maybe later I'll
    # add code so moves will take the amount of time
    # they'd take normally.
    @instant = yes

    # Stream receiving code being written to the
    # machine.
    @writeStream = new Bacon.Bus()
      .name 'machine.writeStream'

    @writeStream.onError (err) ->
      console.error "SimMachine error!"
      console.error err.stack

    # Look for lines and split on newlines.
    @gCodeLines = Bacon.fromBinder (emit) =>
      partial = ''
      @writeStream.onValue (code) ->
        if code.indexOf("\n") < 0
          partial += code
          return
        code = code.split "\n"
        code[0] = partial + code[0]
        for line in code[0...-1]
          emit line
        partial = code.slice -1
      ->

    # Keep track of the state of the machine and
    # emit events appropriate to what the printer
    # is doing.
    @stateMachine = @writeStream.withStateMachine INITIAL_STATE, stateTransform

  # Write the given data out to the printer.
  write: (data) ->
    @writeStream.push data

  # Get an Observable that emits an event when it
  # sees a line come back from the printer.
  getReadStream: ->
    # Return our state machine's events on a delay
    # to simulate serial port latency etc.
    @stateMachine.delay(200)
