{SerialPort} = require 'serialport'
Bacon = require 'baconjs'

_ = require 'lodash'

connections = []

lastId = 1

id = -> lastId++

connectionStream = new Bacon.Bus()

process.on 'exit', ->
  console.log "Closing ports..."
  for cx in connections
    console.log "  Closing port #{cx.info.comName}..."
    cx.close()
  console.log "Done."
  

module.exports =
  push: connections.push.bind(connections)
  map: connections.map.bind(connections)
  any: (f) -> _.any connections, f
  get: (id) -> _.findWhere connections, (cx) -> (""+cx.info.id) is ""+id
  add: (data, callback) ->
    {comName, baudRate} = data
    baudRate ?= 9600
    port = new SerialPort comName, baudRate: baudRate, (err) ->
      if err then return callback err
      port.info =
        id: id()
        comName: comName
        baudRate: baudRate
        opened: +new Date()
      connections.push port
      connectionStream.push port
      callback null, port
  connectionEvents: ->
    connectionStream.map _.identity
