Backbone = require 'backbone'

tpl = require '../../tpl/JogView.jade'

module.exports =
JogView = Backbone.View.extend
  render: ->
    @$el.html tpl(machine: @model)
    @
