Backbone = require 'backbone'
require '../semantic.min.js'

tpl = require '../../tpl/dash.jade'

MachineSettingsDialog = require './MachineSettingsDialog.coffee'

module.exports =
NotConnectedView = Backbone.View.extend
  render: ->
    @$el.html(tpl())
    @$('[data-action="edit"]').off('click').click =>
      dialog = new MachineSettingsDialog()
      dialog.show()
    if @rendered then return @
    @rendered = yes
    @$('.card').hide()
    setTimeout =>
      @$('.card').transition('horizontal flip')
    , 2000
    @
