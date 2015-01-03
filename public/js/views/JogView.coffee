Backbone = require 'backbone'

tpl = require '../../tpl/JogView.jade'

module.exports =
JogView = Backbone.View.extend
  render: ->
    model = @model
    @$el.html tpl(machine: @model)
    @$('.dropdown').dropdown(className: selection: 'inline')
    @$('.dropdown').each ->
      $(@).find('.dropdown.icon').hide()
      $(@).append('<i class="dropdown icon"></i>')
    @$('[data-action="jog"]').each ->
      $btn = $(@)
      $btn.mouseover -> model.trigger "mouseover:#{$btn.attr 'data-axis'}"
      $btn.mouseout -> model.trigger "mouseout:#{$btn.attr 'data-axis'}"
    @
