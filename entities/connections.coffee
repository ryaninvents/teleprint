{SerialPort} = require 'serialport'
Bacon = require 'baconjs'
uuid = require 'node-uuid'

_ = require 'lodash'

connections = []

id = -> uuid.v4()

connectionStream = new Bacon.Bus()

ports = require './ports'

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
    {type} = data
    if ports[type]?
      ports[type] data, (err, port) ->
        if err then return callback err
        connections.push port
        connectionStream.push port
        callback null, port
    else
      callback new Error "No port type specified"

  connectionEvents: ->
    connectionStream.map _.identity
