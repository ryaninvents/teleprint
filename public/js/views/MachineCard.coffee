Backbone = require 'backbone'

tpl = require '../../tpl/MachineCard.jade'

MachineSettingsDialog = require './MachineSettingsDialog.coffee'

module.exports =
MachineCard = Backbone.View.extend
  render: ->
    @$el.html tpl(machine: @model)
    @$el.addClass 'card'
      .css position: 'relative'
    @$('[data-action="edit"]').off('click').click =>
      @dialog ?= new MachineSettingsDialog(model: @model)
      @dialog.show()
    @model.on 'open close', => @updateConnectionStatus()
    @
  updateConnectionStatus: ->
    @$('[data-element="connection-status"]').css 'display', if @model.connected
      'block'
    else
      'none'
  show: ->
    @render()
    @$el.hide()
    # @$el.fadeIn()
    @$el.transition 'horizontal flip in'
    @
  hide: ->
    # @$el.fadeOut()
    @$el.transition 'horizontal flip out', onComplete: =>
     @$el.hide()
