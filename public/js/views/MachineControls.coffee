Backbone = require 'backbone'
Bacon = require 'baconjs'
_ = require 'lodash'

JogView = require './JogView.coffee'
TemperatureView = require './TemperatureView.coffee'
Printer3DView = require './Printer3DView.coffee'
CalibrationDialog = require './CalibrationDialog.coffee'

tpl = require '../../tpl/MachineControls.jade'

module.exports =
MachineControls = Backbone.View.extend
  render: ->
    @$el.html tpl machine: @model

    @jogView = new JogView model: @model
    @$('[data-view="jog"]').html @jogView.render().$el

    @temperatureView = new TemperatureView model: @model
    @$('[data-view="temp"]').html @temperatureView.render().$el

    @printer3DView = new Printer3DView model: @model
    @$('[data-view="printer3D"]').html @printer3DView.render().$el

    @$('[data-action="calibrate"]').click =>
      new CalibrationDialog().show()

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
