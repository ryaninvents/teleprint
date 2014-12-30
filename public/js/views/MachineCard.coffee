Backbone = require 'backbone'
require '../semantic.min.js'

tpl = require '../../tpl/MachineCard.jade'

MachineSettingsDialog = require './MachineSettingsDialog.coffee'

module.exports =
MachineCard = Backbone.View.extend
  render: ->
    @$el.html tpl(machine: @model)
    @$el.addClass 'card'
    @$('[data-action="edit"]').off('click').click =>
      @dialog ?= new MachineSettingsDialog(model: @model)
      @dialog.show()
    @$('.corner.label').css 'display', if @model.get('active')
      'block'
    else
      'none'
    @
  show: ->
    @render()
    @$el.hide()
    @$el.transition 'horizontal flip'
    @
  hide: ->
    @$el.transition 'horizontal flip', onComplete: =>
      @$el.hide()
