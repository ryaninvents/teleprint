opts = require '../../options'
{EventEmitter} = require 'events'
uuid = require 'node-uuid'

# Here's the simulated machine that we'll control.
SimMachine = require '../sim-machine'
machine = new SimMachine
  comName: '/dev/fake'
  pnpId: "SimulatedMachine_09f41dde"

# Here's our fake port that we can write to/read from as if it were real.
port =
  type: 'simulation'
  write: machine.write.bind machine
  getReadStream: machine.getReadStream.bind machine
  comName: machine.attributes.comName
  pnpId: machine.attributes.pnpId

machine.port = port

sim = (data, callback) ->
  {type} = data
  callback new Error 'Not implemented'

sim.list = (callback) ->
  if opts.sim
    callback null, [port]
  else
    callback null, []

module.exports = sim
