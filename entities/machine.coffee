Bacon = require 'baconjs'
opts = require '../options'
sh = require 'shelljs'
uuid = require 'node-uuid'
_ = require 'lodash'
path = require 'path'
machinesPath = path.join __dirname,'../.machines'
dbPath = path.join machinesPath, 'machines.sqlite'
sh.mkdir '-p', machinesPath
db = require('knex')
  client: 'sqlite'
  connection:
    filename: dbPath

module.exports =
# Represents a 3D printer of some sort... maybe in the
# future someone'll want to use this on a wider array of
# devices, so I'm just calling it `Machine` for now.
class Machine
  constructor: (@attributes, @port) ->
    @details = @attributes?.details
  write: (data) -> @port.write.apply @port, arguments
  getReadStream: ->
    Bacon.fromEventTarget @port, 'data'

  # Take a stream of ports and look up each
  # pnpId in the database. If we get a match,
  # push the found machine into the results
  # stream; if not, create a new machine and
  # push it in.
  @fromPortStream: (portStream) ->
    portStream.flatMap (port) ->
      Bacon.fromNodeCallback(
        db('machines').select('*')
          .where pnpId: port.info.pnpId
          .exec
      ).map (results) ->
        row = null
        if results.length
          row = results[0]
        else
          id = uuid.v4()
          row =
            uuid: id
            pnpId: port.info.pnpId
            name: "Machine #{id[-6..-1].toUpperCase()} on port #{port.info.comName}"
        new Machine(row, port)
