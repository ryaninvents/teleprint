Backbone = require 'backbone'
Bacon = require 'baconjs'
io = require '../../socket.io'
_ = require 'lodash'

module.exports =
Machine = Backbone.Model.extend
  initialize: ->
    if @attributes.connected?
      @connected = @get 'connected'
      delete @attributes.connected
    if @connected
      @trigger 'open'
    @on 'open', => @connected = yes; console.log 'machine connected'
    @on 'close', => @connected = no; console.log 'machine disconnected'
  idAttribute: 'uuid'
  meta: ->
    switch @get 'type'
      when 'serial' then "#{@get('details')?.baudrate or 'Unknown'} baudrate"
      when 'sim' then "Simulated machine"
      else "#{@get('details')?.baudrate or 'Unknown'} baudrate (#{@get 'type'})"
  hasImage: -> @get 'hasImage'
  socket: ->
    if @_socket? then return @_socket
    @_socket = io("/machines/#{@id}")
    @_socket.on 'change', (json) => @set json
    @_socket.on 'open', => @trigger 'open'
    @_socket.on 'close', => @trigger 'close'
    @_socket.on 'write', (data) => @trigger 'write', data
    @_socket.on 'data', (data) => @trigger 'data', data
    @_socket.on 'err', (data) => @trigger 'err', data
    @_socket
  write: (data) ->
    @socket().emit 'method', 'write', data
  connect: ->
    @socket().emit 'method', 'connect'
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
