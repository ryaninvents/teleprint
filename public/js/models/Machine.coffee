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
    @on 'change', (model, opt) => unless opt.via is 'socket' then @sendChanges()
    @socketConnected = (Machine.list.status is 'connected')
  idAttribute: 'uuid'
  meta: ->
    switch @get 'type'
      when 'serial' then "#{@get('details')?.baudrate or 'Unknown'} baudrate"
      when 'sim' then "Simulated machine"
      else "#{@get('details')?.baudrate or 'Unknown'} baudrate (#{@get 'type'})"
  hasImage: -> Boolean @get 'image'
  socket: ->
    if @_socket? then return @_socket
    @_socket = io("/machines/#{@id}")
    @_socket.on 'change', (json) => @set json, via: 'socket'
    @_socket.on 'open', => @trigger 'open'
    @_socket.on 'close', => @trigger 'close'
    @_socket.on 'write', (data) => @trigger 'write', data
    @_socket.on 'data', (data) => @trigger 'data', data
    @_socket.on 'err', (data) => @trigger 'err', data
    # Hook into the global machine-list socket to check server state.
    ['connect','reconnect'].forEach (EVENT) =>
      socket.on EVENT, => @socketConnected = yes
    socket.on 'disconnect', => @socketConnected = no
    @_socket
  write: (data) ->
    @socket().emit 'method', 'write', data
  connect: ->
    @socket().emit 'method', 'connect'
  sendChanges: ->
    @socket().emit 'change', @changedAttributes()
,
  getByID: (id) ->
    Machine.list.find (m) -> m.id is id

Machine.Collection = Backbone.Collection.extend
  url: '/api/machines'
  model: Machine

Machine.list = new Machine.Collection()
Machine.list.status = 'disconnected'
Machine.ready = (fn) ->
  Machine.list.on 'ready', _.once fn

socket = io('/machines')
socket.on 'initial-list', (machines) ->
  console.log 'initial-list', machines
  Machine.list.set []
  Machine.list.set machines.map (m) -> new Machine m
  Machine.list.trigger 'ready'
  Machine.ready = (fn) -> fn()
socket.on 'add', (machine) ->
  Machine.list.add new Machine machine
socket.on 'remove', (json) ->
  {uuid} = json
  machine = Machine.list.filter((m) -> m.id is uuid)[0]
  return unless machine?
  Machine.list.remove machine
onSockConnect = ->
  $.toast text: 'Connected to server', showHideTransition: 'plain', allowToastClose: no
  Machine.list.trigger 'connect'
  Machine.list.status = 'connected'
onSockDisconnect = ->
  $.toast text: 'Server connection lost', showHideTransition: 'plain', allowToastClose: no
  Machine.list.trigger 'disconnect'
  Machine.list.status = 'disconnected'


socket.on 'connect', onSockConnect
socket.on 'disconnect', onSockDisconnect
