Backbone = require 'backbone'

NotConnectedView = require './views/NotConnectedView.coffee'

module.exports =
Router = Backbone.Router.extend
  routes:
    "": "machine"
    "machine": "machine"
    "model": "model"
    "settings": "settings"
  machine: ->
    view = new NotConnectedView()
    $('.main').html(view.render().$el)
  model: -> console.log 'model route!'
  settings: -> console.log 'settings route, oooo'
