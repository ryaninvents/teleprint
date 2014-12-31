Backbone = require 'backbone'
opts = require '../options'
sh = require 'shelljs'
uuid = require 'node-uuid'
_ = require 'lodash'
path = require 'path'
Bacon = require 'baconjs'
Port = require './port'
require('../backbone.eventstreams')(Backbone)

machinesPath = path.join __dirname,'../.machines'
dbPath = path.join machinesPath, 'machines.sqlite'
sh.mkdir '-p', machinesPath
db = require('knex')
  client: 'sqlite'
  connection:
    filename: dbPath

machineList = null

module.exports =
# # Class Machine
Machine = Backbone.Model.extend
  initialize: ->
    if @get('port')?
      @port = @get 'port'
      delete @attributes.port
      @set 'pnpId', @port.get 'pnpId'
      @port.on 'open', =>
        @trigger 'open'
        @set 'connected', yes
      @port.on 'close', =>
        @trigger 'close'
        @set 'connected', no
      @port.on 'error', (e) =>
        @trigger 'err', e.toString()
      @port.on 'data', (data) =>
        @trigger 'data', data
      @port.on 'write', (data) => @trigger 'write', data
  connect: ->
    unless @get 'connected'
      @port.open()
  disconnect: ->
    if @get 'connected'
      @port.close()
  write: (data) ->
    if @get 'connected'
      @port.write data
    else
      @trigger 'error', "Cannot write to machine; not connected"
  runMethod: (method, args) ->
    switch method
      when 'write'
        @write.apply @, args
      when 'connect', 'open'
        @connect()
      when 'disconnect', 'close'
        @disconnect()
      else
        if _.isFunction @code?[method]
          @code[method].apply @transform, args.concat (err, code) =>
            if err
              console.error err.stack
              return @trigger 'error', err.toString()
            @write code
        else
          codeName = @code.constructor.name
          @trigger 'error', "#{codeName}.#{method} is not a method"
,
# ## Static methods
  listVisible: -> machineList

# ### lookup()
#
# Find a machine based on its port's pnpId, or
# create a new machine if we haven't seen this
# one before.
#
# Returns a stream that will emit a single
# machine and then close.
  lookup: (port) ->
    withPnpMatch = (m) ->
      m.port.get('pnpId') is port.get('pnpId')

    if m = machineList.find withPnpMatch
      return Bacon.once m
    console.log "Matching on #{port.get 'pnpId'}"
    stream = Bacon.fromPromise(
      db('machines').select('*')
        .where pnpId: port.get('pnpId')
    ).map (results) ->
      console.log "Found #{results.length} results"
      if results.length
        row = results[0]
        row.port = port
      else
        id = uuid.v4()
        row =
          uuid: id
          pnpId: port.get 'pnpId'
          name: "Machine #{id[0...6].toUpperCase()}"
          saved: no
          type: port.constructor.type()
          hasImage: no
          port: port
      machine = new Machine(row)
    saveStream = stream.filter (machine) -> machine.get('pnpId') and (machine.get('saved') is no)
      .flatMap (machine) ->
        console.log "Saving machine #{machine.get('uuid')[0..6].toUpperCase()}"
        toSave =
          uuid: machine.get 'uuid'
          pnpId: machine.get 'pnpId'
          name: machine.get 'name'
          type: machine.get 'type'
          hasImage: machine.get 'hasImage'
          details: _.omit machine.attributes, (val, key) ->
            key in ['saved','uuid','pnpId','name','type']
        Bacon.fromPromise(db.insert(toSave).into('machines')).map -> machine
    saveStream.onValue (machine) ->
        console.log "Successfully saved machine #{machine.get('uuid')[0...6].toUpperCase()}"
    saveStream.onError (err) -> console.error err.toString()
    return stream.doAction (m) -> delete m.attributes.saved


# # Machine.Collection
Machine.Collection = Backbone.Collection.extend
  model: Machine

machineList = new Machine.Collection

portTypes = Port.types()


db.migrate.latest
  directory: path.join __dirname, '../migrations'
.then ->
  portTypes.forEach (type) ->
    addByPort = (p) ->
      Machine.lookup(p).onValue (machine) ->
        machineList.push machine
    ports = type.enumerate()
    console.log type.longname(), ports.map (p) -> p.toJSON()
    ports.forEach addByPort
    ports.on 'add', addByPort
# TODO implement this
    ports.on 'remove', (port) ->

process.on 'exit', ->
  console.log "Closing connections..."
  for m in machineList.models
    console.log "  Closing connection to machine #{m.get 'name'}..."
    m.disconnect()
  console.log "Done."
