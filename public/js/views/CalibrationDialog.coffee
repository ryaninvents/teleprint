tpl = require './CalibrationDialog.jade'
Backbone = require 'backbone'
Bacon = require 'baconjs'
Machine = require '../models/Machine.coffee'
_ = require 'lodash'

module.exports =
CalibrationDialog = Backbone.View.extend

  initialize: ->
    @unit = 'in'

  render: ->
    self = @
    @$el.html tpl()
    @$('[data-hook="units"]').click ->
      if self.unit is 'in'
        $(@).text(self.unit = 'mm')
      else
        $(@).text(self.unit = 'in')
    @$('[data-hook="not-touching"]').click =>
      @setDim(yes)
      setTimeout (=> @setDim(no)), 2000
    @

  show: ->
    @$modal = @render().$el
    $('#dialog-area').empty().append @$modal
    $('#dialog-area .ui.modal').modal "show"

  hide: ->
    @$modal.modal "hide"
    @$modal.remove()

  setDim: (isDim) ->
    @$('.dimmer').addClass('active', isDim)
