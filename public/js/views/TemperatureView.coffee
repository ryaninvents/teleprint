Backbone = require 'backbone'

tpl = require '../../tpl/TemperatureView.jade'

module.exports =
TemperatureView = Backbone.View.extend
  render: ->
    @$el.addClass('ui grid').html tpl(machine: @model)
    @$('.dropdown').dropdown()
    @$('.ui.checkbox').checkbox()
    @$('.dropdown[data-field="extruder-temp"]').each ->
      $input = $(@).find 'input[type="number"]'
      $text = $(@).find 'text'
      $input.asEventStream('keyup')
        .filter (e) -> e.which is 13
        .merge($input.asEventStream 'change')
        .merge($input.asEventStream 'scroll')
        .map -> $input.val()
        .onValue (temp) =>
          console.log temp
          $(@).dropdown 'set text', "#{temp}&deg;C"
    @
