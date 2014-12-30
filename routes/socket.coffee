io = require 'socket.io'
Bacon = require 'baconjs'

module.exports = (server) ->
  ioServ = io(server, serveClient: yes)

  require('./socket/machines')(ioServ)

  console.log "Attached socket server"

