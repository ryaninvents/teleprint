Backbone = require 'backbone'

module.exports =
Machine = Backbone.Model.extend
  idAttribute: 'uuid'
  meta: ->
    switch @get 'type'
      when 'serial' then "#{@get('details')?.baudrate or 'Unknown'} baudrate"
      when 'simulation' then "Simulated machine"
      else ''
  hasImage: -> @get 'hasImage'

Machine.Collection = Backbone.Collection.extend
  url: '/api/machines'
  model: Machine
