Bacon = require 'baconjs'
Machine = require '../../models/machine'

module.exports = (ioServ) ->
  machines = ioServ.of("/machines")
  connections = Bacon.fromEventTarget machines, 'connection'
  connections.onValue (socket) ->
    socket.emit 'initial-list', Machine.listVisible().models

# Bind action handlers to the socket
  for ACTION in ['add','remove']
    Machine.listVisible().on ACTION, (machine) ->
      machines.emit ACTION, machine.toJSON()

# Create a new namespace for each machine
  Machine.listVisible().on 'add', (machine) ->
    socket = ioServ.of("/machines/#{machine.id}")
    machineActions = [
      'change'
      'connect'
      'disconnect'
      'write'
      'data'
      'error'
    ]
    for ACTION in machineActions
      machine.on ACTION, (machine) ->
        socket.emit ACTION, machine.toJSON()
    socket.on 'connect', -> machine.connect()
    socket.on 'disconnect', -> machine.disconnect()
    socket.on 'change', (json) ->
      machine.set json
    socket.on 'method', (method, args) ->
      machine.runMethod method, args
