Backbone = require 'backbone'
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
    setTimeout =>
      @collection.each @onAdd.bind @
      @collection.on 'add', @onAdd.bind @
      @collection.on 'remove', @onRemove.bind @
    , 100
  onSync: ->
    @$('.instructions').text if @collection.size()
      "Choose a machine to connect to."
    else
      "No machines found."
  onAdd: (model) ->
    card = @cards[model.id] ?= new MachineCard(model: model)
    card.render()
    unless $.contains @$el, card.$el
      @$('.cards').append card.$el
    card.show()
    model.on 'open close', @updateHeader.bind @
    @updateHeader()
    @onSync()
  onRemove: (model) ->
    card = @cards[model.id]
    card.hide()
    @onSync()
  updateHeader: ->
    $h2 = @$('h2')
    count = @collection.filter((m) -> m.connected).length
    text = if count is 0
      "No machines connected"
    else if count is 1
      "1 machine connected"
    else
      "#{count} machines connected"
    $h2.text text
  render: ->
    @$el.html(tpl())
    _.forOwn @cards, (card) =>
      @$('.cards').append card.render().$el
    @onSync()
    @
