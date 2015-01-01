Backbone = require 'backbone'

tpl = require '../../tpl/TemperatureView.jade'

module.exports =
TemperatureView = Backbone.View.extend
  render: ->
    @$el.addClass('ui grid').html tpl(machine: @model)
    @$('.dropdown').dropdown()
    @
