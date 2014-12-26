Backbone = require 'backbone'
require '../semantic.min.js'

tpl = require '../../tpl/MachineSettingsDialog.jade'

module.exports =
MachineSettingsDialog = Backbone.View.extend
  render: ->
    @$el.html tpl()
    @$el.addClass 'ui modal'
    @

  show: ->
    @render()
    $('#dialog-area').html('').append @$el
    @$el.modal 'show'

  hide: -> @$el.modal 'hide'
