Backbone = require 'backbone'

Machine = require './models/Machine.coffee'
MachineControls = require './views/MachineControls.coffee'
MachineSelectionView = require './views/MachineSelectionView.coffee'

module.exports =
Router = Backbone.Router.extend
  routes:
    "": "selectMachine"
    "model": "model"
    "settings": "settings"
    "machine/:id": "machine"
  selectMachine: ->
    @view ?= new MachineSelectionView()
    $('.main').html(@view.render().$el)
    $('#side-menu > .item').removeClass('active')
    $('#machine').addClass('active')
  machine: (id) ->
    Machine.ready ->
      machine = Machine.getByID(id)
      view = new MachineControls(model:machine)
      $('.main').html view.render().$el
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
