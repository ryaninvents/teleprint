Backbone = require 'backbone'

tpl = require '../../tpl/MachineSettingsDialog.jade'

module.exports =
MachineSettingsDialog = Backbone.View.extend
  render: ->
    @$el.html tpl(machine: @model)
    @$el.addClass 'ui modal'
    @$('.actions .button').one 'click', =>
      @hide()
    @

  show: ->
    @render()
    $('#dialog-area').html('').append @$el
    @$el.modal 'show'

  hide: -> @$el.modal 'hide'
