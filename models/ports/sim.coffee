Bacon = require 'baconjs'

Port = require '../port'
SimMachine = require '../sim-machine'
opts = require '../../options'

ports = new Port.Collection()

module.exports =
SimPort = Port.extend
  initialize: ->
    @machine = new SimMachine
# Type of printer geometry: `cartesian`, `delta`, or `corexy`.
      geometry: @get('geometry') ? 'cartesian'
# Bed bounds in mm. Default print bed is 200x200.
      bedBounds: @get('bedBounds') ? [[0,0],[200,200]]
# Printer volume height.
      height: @get('height') ? 200

    str = @machine.getReadStream()
    str.onValue (data) =>
      @trigger 'data', data
    str.onError (err) =>
      console.error "Port error!", err.stack
      @trigger 'error', err
  open: -> @trigger 'open'
  close: -> @trigger 'close'
  write: (data)->
    return unless data.length
    @machine.write data
    @trigger 'write', data
  flush: ->
# ## Static methods
,
  enumerate: -> ports
  type: -> "sim"
  longname: -> "Simulated machine"
  description: ->
    "A simulation of a 3D printer."


if opts.sim
  ports.push new SimPort
    pnpId: "SimulatedMachine_09f41dde"
    comName: "/dev/fake"
