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
    @view ?= new NotConnectedView()
    $('.main').html(@view.render().$el)
    $('#side-menu > .item').removeClass('active')
    $('#machine').addClass('active')
  model: ->
    $('.main').html('<input type="file" id="file-select"/><a class="ui button">Pick file</a>')
    $('.main a.button').click =>
      $('#file-select').click()
    $('#side-menu > .item').removeClass('active')
    $('#model').addClass('active')
  settings: ->
    $('.main').html('<a class="ui red button">Refresh</a>')
    $('.main a.button').click =>
      $(this).text 'Reloading...'
      document.location.reload()
    $('#side-menu > .item').removeClass('active')
    $('#settings').addClass('active')
