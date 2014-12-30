Backbone = require 'backbone'
require '../semantic.min.js'
_ = require 'lodash'
Bacon = require 'baconjs'

tpl = require '../../tpl/MachineSelectionView.jade'

MachineSettingsDialog = require './MachineSettingsDialog.coffee'
MachineCard = require './MachineCard.coffee'
Machine = require '../models/Machine.coffee'

cxDiff = (big, little) ->
  _.reject big, (i1) ->
    _.some little, (i2) -> i1.id is i2.id

module.exports =
MachineSelectionView = Backbone.View.extend
  initialize: ->
    MachineSelectionView.collection ?= Machine.list
    {@collection} = MachineSelectionView
    @cards = {}
    @collection.on 'add', (model) => @onAdd model
    @collection.on 'remove', (model) => @onRemove model
  onSync: ->
    @$('.instructions').text if @collection.size()
      "Choose a machine to connect to."
    else
      "No machines found."
  onAdd: (model) ->
    card = @cards[model.id] ?= new MachineCard(model: model)
    card.render()
    unless card.$el.is ':visible'
      @$('.cards').append card.$el
      card.show()
    @onSync()
  onRemove: (model) ->
    card = @cards[model.id]
    card.hide()
    @onSync()
  render: ->
    @$el.html(tpl())
    _.forOwn @cards, (card) =>
      @$('.cards').append card.render().$el
    ###
    if @rendered then return @
    @rendered = yes
    @$('.card').hide()
    setTimeout =>
      @$('.card').transition('horizontal flip')
    , 2000
    ###
    @
