Backbone = require 'backbone'
Bacon = require 'baconjs'
_ = require 'lodash'

JogView = require './JogView.coffee'
TemperatureView = require './TemperatureView.coffee'

tpl = require '../../tpl/MachineControls.jade'

module.exports =
MachineControls = Backbone.View.extend
  render: ->
    @$el.html tpl machine: @model

    @jogView = new JogView model: @model
    @$('[data-view="jog"]').html @jogView.render().$el

    @temperatureView = new TemperatureView model: @model
    @$('[data-view="temp"]').html @temperatureView.render().$el

    $gcodeInput = @$('[data-element="gcode-input"]')
    $gcodeInput.asEventStream('keyup')
      .filter (key) -> key.which is 13
      .map -> $gcodeInput.val()
      .onValue (code) =>
        $gcodeInput.val('')
        @model.write "#{code}\n"
    @model.on 'write', (data) =>
      @$('pre').append ">> #{data.trim()}\n"
    @model.on 'data', (data) =>
      @$('pre').append "<< #{data.trim()}\n"
    @
