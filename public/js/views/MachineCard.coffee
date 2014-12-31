Backbone = require 'backbone'

tpl = require '../../tpl/MachineCard.jade'

MachineSettingsDialog = require './MachineSettingsDialog.coffee'
Machine = require '../models/Machine.coffee'

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
    @model.on 'change:name', =>
      @$('[data-field="name"]').text @model.get 'name'
    @model.on 'change:image', =>
      image = @model.get 'image'
      @$('.ui.image').css
        'background-image': if image then "url(#{image})" else ''
      @$('.ui.image').toggleClass('with-image', Boolean(image)).toggleClass('without-image', Boolean(not image))
    Machine.list.on 'connect disconnect', => @updateConnectionStatus()
    @
  updateConnectionStatus: ->
    $ribbon = @$('[data-element="connection-status"]')
    $ribbon.css 'display', if @model.connected
      'block'
    else
      'none'
    ribbonClass = if @model.socketConnected then 'green' else 'gray'
    ribbonText = if @model.socketConnected then 'Connected' else '--'
    $ribbon.removeClass('green gray').addClass(ribbonClass).text(ribbonText)
  show: ->
    @render()
    @$el.hide()
    @$el.transition 'horizontal flip in'
    @
  hide: ->
    @$el.transition 'horizontal flip out', onComplete: =>
     @$el.hide()
