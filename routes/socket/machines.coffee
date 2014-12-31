Bacon = require 'baconjs'
Machine = require '../../models/machine'
_ = require 'lodash'

module.exports = (ioServ) ->
  machines = ioServ.of("/machines")
  connections = Bacon.fromEventTarget machines, 'connection'
  connections.onValue (socket) ->
    socket.emit 'initial-list', Machine.listVisible().models

# Bind action handlers to the socket
  for ACTION in ['add','remove']
    Machine.listVisible().on ACTION, (machine) ->
      machines.emit ACTION, machine.toJSON()

  hookSockets = (machine) ->
    sockets = ioServ.of("/machines/#{machine.get 'uuid'}")
    console.log "Creating namespace #{sockets.name}"
    sockets.on 'connection', (socket) ->
      console.log "Connected to #{machine.get 'name'}"

# This needs to be a `forEach` so we don't clobber the value of `ACTION`.
      ['change','open','close'].forEach (ACTION) ->
        machine.on ACTION, () ->
          socket.emit ACTION, machine.toJSON()
      ['write','data','err'].forEach (ACTION) ->
        machine.on ACTION, (data) ->
          socket.emit ACTION, data
      socket.on 'change', (json) ->
        console.log "set", json
        machine.set json
      socket.on 'method', (method, args) ->
        args = [args] unless _.isArray args
        machine.runMethod method, args

# Create a new namespace for each machine
  Machine.listVisible().on 'add', hookSockets
  Machine.listVisible().forEach hookSockets
