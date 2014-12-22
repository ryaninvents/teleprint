io = require 'socket.io'
connections = require '../entities/connections'
Bacon = require 'baconjs'

module.exports = (server) ->
  ioServ = io(server, serveClient: yes)

  connect = connections.connectionEvents().doAction (port) ->
    ioServ.of("/connections/#{port.info.id}")

  socket = connect.flatMap (port) ->
    Bacon.fromEventTarget ioServ.of("/connections/#{port.info.id}"), 'connection'
      .map (socket) ->
        portID = socket.nsp?.name?.match(/connections\/(\d+)/)
        unless portID?.length
          return socket
        console.log "Connecting on #{portID[1]}"
        socket.port = connections.get portID[1]
        socket

  socket.flatMap (socket) ->
    Bacon.fromEventTarget socket, 'machine code'
      .map (code) -> port: socket.port, code: code
  .onValue (ev) ->
    {port, code} = ev
    port.write code

  socket.flatMap (socket) ->
    Bacon.fromEventTarget socket.port, 'data'
      .map (data) -> socket: socket, data: data
  .onValue (ev) ->
    {socket, data} = ev
    socket.emit 'serial in', data


  console.log "Attached socket server"

