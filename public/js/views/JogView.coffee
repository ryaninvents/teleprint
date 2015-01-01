Backbone = require 'backbone'

tpl = require '../../tpl/JogView.jade'

module.exports =
JogView = Backbone.View.extend
  render: ->
    @$el.html tpl(machine: @model)
    @$('.dropdown').dropdown(className: selection: 'inline')
    @$('.dropdown').each ->
      $(@).find('.dropdown.icon').hide()
      $(@).append('<i class="dropdown icon"></i>')
    @
