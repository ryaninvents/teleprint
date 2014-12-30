Bacon = require 'baconjs'
Backbone = require 'backbone'
opts = require '../options'
sh = require 'shelljs'
uuid = require 'node-uuid'
_ = require 'lodash'
path = require 'path'
ports = require './ports'
require('../backbone.eventstreams')(Backbone)

machinesPath = path.join __dirname,'../.machines'
dbPath = path.join machinesPath, 'machines.sqlite'
sh.mkdir '-p', machinesPath
db = require('knex')
  client: 'sqlite'
  connection:
    filename: dbPath

machineList = []

module.exports =
# Represents a 3D printer of some sort... maybe in the
# future someone'll want to use this on a wider array of
# devices, so I'm just calling it `Machine` for now.
Machine = Backbone.Model.extend
  initialize: (@attributes, @port) ->
    @details = @attributes?.details
  write: (data) -> @port.write.apply @port, arguments
  get: (attr) -> @attributes[attr]
  set: (attr, val) -> @attributes[attr] = val
  getReadStream: ->
    Bacon.fromEventTarget @port, 'data'
  toJSON: ->
    json = _.clone @attributes
    json.port = @port
    json.type ?= @get('type') or @port.type
    json.hasImage = Boolean json.hasImage
    json
,
  list: ->
    Machine.fromPortStream ports.list()

  # Take a stream of ports and look up each
  # pnpId in the database. If we get a match,
  # push the found machine into the results
  # stream; if not, create a new machine and
  # push it in.
  fromPortStream: (portStream) ->
    stream = portStream.flatMap (port) ->
      if mch = _.find(machineList, (m) -> m.get('pnpId') is (port.pnpId or port.info?.pnpId))
        return Bacon.once mch
      Bacon.fromPromise(
        db('machines').select('*')
          .where pnpId: port.pnpId or port.info?.pnpId
      ).map (results) ->
        row = null
        if results.length
          row = results[0]
        else
          id = uuid.v4()
          row =
            uuid: id
            pnpId: port.pnpId or port.info?.pnpId
            name: "Machine #{id[-6..-1].toUpperCase()}"
            saved: no
            type: port.type or port.info?.type
            hasImage: no
        machine = new Machine(row, port)
        machineList.push machine
        machine
    saveStream = stream.filter (machine) -> (machine.get 'pnpId') and (machine.get('saved') is no)
      .flatMap (machine) ->
        console.log "Saving machine #{machine.get('uuid')[-6..-1].toUpperCase()}"
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
        console.log "Successfully saved machine #{machine.get('uuid')[-6..-1].toUpperCase()}"
    saveStream.onError (err) -> console.error err.toString()
    return stream.doAction (m) -> delete m.attributes.saved
