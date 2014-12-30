Backbone = require 'backbone'
Bacon = require 'baconjs'
io = require '../../socket.io'
_ = require 'lodash'

module.exports =
Machine = Backbone.Model.extend
  initialize: ->
    @on 'write', (data) -> console.log ">> #{data}"
    @on 'data', (data) -> console.log "<< #{data}"
  idAttribute: 'uuid'
  meta: ->
    switch @get 'type'
      when 'serial' then "#{@get('details')?.baudrate or 'Unknown'} baudrate"
      when 'sim' then "Simulated machine"
      else "#{@get('details')?.baudrate or 'Unknown'} baudrate (#{@get 'type'})"
  hasImage: -> @get 'hasImage'
  hookSocket: ->
    if @socket? then return @socket
    @socket = io("/machines/#{@id}")
    console.log "Connecting to socket namespace /machines/#{@id}"
    @socket.on 'change', (json) => @set json
    @socket.on 'open', => @connected = yes
    @socket.on 'close', => @connected = no
    @socket.on 'write', (data) => @trigger 'write', data
    @socket.on 'data', (data) => @trigger 'data', data
    @socket.on 'err', (data) => @trigger 'err', data
    @socket
  write: (data) ->
    @hookSocket().emit 'method', 'write', data
  connect: ->
,
  getByID: (id) ->
    Machine.list.find (m) -> m.id is id

Machine.Collection = Backbone.Collection.extend
  url: '/api/machines'
  model: Machine

Machine.list = new Machine.Collection()
Machine.ready = (fn) ->
  Machine.list.on 'ready', _.once fn

socket = io('/machines')
socket.on 'initial-list', (machines) ->
  console.log 'initial-list', machines
  Machine.list.set machines.map (m) -> new Machine m
  Machine.list.trigger 'ready'
  Machine.ready = (fn) -> fn()
socket.on 'add', (machine) ->
  Machine.list.add new Machine machine
socket.on 'remove', (machine) ->
  Machine.list.findWhere(id:machine.id)?.destroy()
