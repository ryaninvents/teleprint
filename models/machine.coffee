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
  connect: ->
    @port.open()
    throw new Error 'not done yet'
  disconnect: ->
    @port.close()
    throw new Error 'not done yet'
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
    stream = Bacon.fromPromise(
      db('machines').select('*')
        .where pnpId: port.get('pnpId')
    ).map (results) ->
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
    saveStream = stream.filter (machine) -> machine.get('pnpId') and (not machine.get 'saved')
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
