Backbone = require 'backbone'
Bacon = require 'baconjs'
_ = require 'lodash'

tpl = require '../../tpl/MachineControls.jade'

module.exports =
MachineControls = Backbone.View.extend
  render: ->
    @$el.html tpl machine: @model
    $gcodeInput = @$('[data-element="gcode-input"]')
    $gcodeInput.asEventStream('keyup')
      .filter (key) -> key.which is 13
      .map -> $gcodeInput.val()
      .onValue (code) =>
        $gcodeInput.val('')
        @model.write "#{code}\n"
    @model.on 'write', (data) =>
      @$('pre').append ">> #{data}\n"
    @model.on 'data', (data) =>
      @$('pre').append "<< #{data}\n"
    @
