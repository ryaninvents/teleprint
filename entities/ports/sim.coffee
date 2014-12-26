opts = require '../../options'

sim = (data, callback) ->
  {type} = data
  callback new Error 'Not implemented'

sim.list = (callback) ->
  #if opts.sim
  callback null, []

module.exports = sim
