Bacon = require 'baconjs'

Driver = require '../driver'
SimMachine = require '../sim-machine'
opts = require '../../options'

drivers = new Driver.Collection()

module.exports =
SimDriver = Driver.extend
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
      console.error "Driver error!", err.stack
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
  enumerate: -> drivers
  type: -> "sim"
  longname: -> "Simulated machine"
  description: ->
    "A simulation of a 3D printer."
  options: ->


if opts.sim
  drivers.push new SimDriver
    pnpId: "SimulatedMachine_09f41dde"
    comName: "/dev/fake"
