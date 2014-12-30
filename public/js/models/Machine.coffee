Backbone = require 'backbone'
Bacon = require 'baconjs'

module.exports =
Machine = Backbone.Model.extend
  idAttribute: 'uuid'
  meta: ->
    switch @get 'type'
      when 'serial' then "#{@get('details')?.baudrate or 'Unknown'} baudrate"
      when 'simulation' then "Simulated machine"
      else "#{@get('details')?.baudrate or 'Unknown'} baudrate (#{@get 'type'})"
  hasImage: -> @get 'hasImage'
  connect: ->
    Bacon.fromPromise $.post "/api/machines/#{@id}/connect"
,
  ensureInit: ->
    Machine.list ?= new Machine.Collection()
  getByID: (id) ->
    Machine.ensureInit()
    results = Bacon.fromEventTarget Machine.list, 'sync'
      .map -> Machine.list.find (m) -> m.id is id
    Machine.list.fetch()
    results

Machine.Collection = Backbone.Collection.extend
  url: '/api/machines'
  model: Machine
