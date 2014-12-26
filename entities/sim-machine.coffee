_ = require 'lodash'
Bacon = require 'baconjs'
Machine = require './machine'

module.exports =
class SimMachine extends Machine
  constructor: ->
    super
    @state = require './sim-default-state'
    @readStream = new Bacon.Bus()
  write: (data) ->
  getReadStream: (data) ->

