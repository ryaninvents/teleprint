Backbone = require 'backbone'

tpl = require '../../tpl/dash.jade'

module.exports =
NotConnectedView = Backbone.View.extend
  render: ->
    @$el.html(tpl())
    @
