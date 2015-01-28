Backbone = require 'backbone'
opts = require '../options'
sh = require 'shelljs'
uuid = require 'node-uuid'
_ = require 'lodash'
path = require 'path'
Bacon = require 'baconjs'
Driver = require './driver'
DeltaBot = require '../math/deltabot'

require('../backbone.eventstreams')(Backbone)

# Set up the database.
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
    @details ?= {}
    if @get('driver')?
      @driver = @get 'driver'
      delete @attributes.driver
      @set 'pnpId', @driver.get 'pnpId'
      @driver.on 'open', =>
        @trigger 'open'
        @set 'connected', yes
      @driver.on 'close', =>
        @trigger 'close'
        @set 'connected', no
      @driver.on 'error', (e) =>
        @trigger 'err', e.toString()
      @driver.on 'data', (data) =>
        @trigger 'data', data
      @driver.on 'write', (data) => @trigger 'write', data

    # TODO break this out; delta stuff shouldn't be hardcoded
    @deltaBot = new DeltaBot(details)

    saveOn = ['name','image'].concat _.keys @driver.constructor.options()
    @on 'change', () =>
      isect = _.intersection(saveOn, _.keys(@changedAttributes()))
      if isect.length
        @save()
    # TODO break this out; delta stuff shouldn't be hardcoded
    @on 'change:details', =>
      @deltaBot.armLength = @details.armLength
      @deltaBot.bedRadius = @details.bedRadius


  defaults: ->
    image: ''


  connect: ->
    unless @get 'connected'
      @driver.open()


  disconnect: ->
    if @get 'connected'
      @driver.close()


  write: (data) ->
    if @get 'connected'
      @driver.write data
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


  save: ->
    detailFields = @driver.constructor.options()
    details = _.mapValues detailFields, (field) => @get field
    row =
      pnpId: @get 'pnpId'
      name: @get 'name'
      type: @get 'type'
      image: @get 'image'
      details: details
    db('machines')
      .where('uuid','=',@get 'uuid')
      .update row
      .catch (err) => @trigger 'err', err.stack.toString()

,
# ## Static methods
  listVisible: -> machineList


# ### lookup()
#
# Find a machine based on its driver's pnpId, or
# create a new machine if we haven't seen this
# one before.
#
# Returns a stream that will emit a single
# machine and then close.
  lookup: (driver) ->
    withPnpMatch = (m) ->
      m.driver.get('pnpId') is driver.get('pnpId')

    if m = machineList.find withPnpMatch
      return Bacon.once m
    stream = Bacon.fromPromise(
      db('machines').select('*')
        .where pnpId: driver.get('pnpId')
    ).map (results) ->
      if results.length
        row = results[0]
        row.driver = driver
      else
        id = uuid.v4()
        row =
          uuid: id
          pnpId: driver.get 'pnpId'
          name: "Machine #{id[0...6].toUpperCase()}"
          saved: no
          type: driver.constructor.type()
          image: ''
          driver: driver
      machine = new Machine(row)
    saveStream = stream.filter (machine) -> machine.get('pnpId') and (machine.get('saved') is no)
      .flatMap (machine) ->
        toSave =
          uuid: machine.get 'uuid'
          pnpId: machine.get 'pnpId'
          name: machine.get 'name'
          type: machine.get 'type'
          image: machine.get 'image'
          details: _.omit machine.attributes, (val, key) ->
            key in ['saved','uuid','pnpId','name','type', 'image', 'details']
        Bacon.fromPromise(db.insert(toSave).into('machines')).map -> machine
    saveStream.onError (err) -> console.error err.toString()
    return stream.doAction (m) -> delete m.attributes.saved


# # Machine.Collection
Machine.Collection = Backbone.Collection.extend
  model: Machine

machineList = new Machine.Collection

portTypes = Driver.types()

# Make sure our database is up-to-date.
db.migrate.latest
  directory: path.join __dirname, '../migrations'
.then ->
  # Find which machines are plugged in already on startup.
  portTypes.forEach (type) ->
    addByDriver = (p) ->
      Machine.lookup(p).onValue (machine) ->
        machineList.push machine
    removeByDriver = (p) ->
      machine = (machineList.filter (machine) ->
        machine.get('pnpId') is p.get('pnpId')
      )[0]
      unless machine?
        return
      machineList.remove machine
    ports = type.enumerate()
    ports.forEach addByDriver
    ports.on 'add', addByDriver
    ports.on 'remove', removeByDriver

# Close any connections to machines on process exit.
# Not great; process exit prevents any callbacks, so any async cleanup
# won't happen. However, having this here does make me feel good about
# myself.
process.on 'exit', ->
  console.log "Closing connections..."
  for m in machineList.models
    console.log "  Closing connection to machine #{m.get 'name'}..."
    m.disconnect()
  console.log "Done."
