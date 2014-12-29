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
    MachineSelectionView.collection ?= new Machine.Collection()
    {@collection} = MachineSelectionView
    unless MachineSelectionView.updateStream?
      update = MachineSelectionView.updateStream = Bacon.interval(2000)
      update.onValue =>
        @collection.fetch()
    @seen = []
    @cards = {}
    @collection.on 'sync', => @onSync()
    @collection.fetch()
  onSync: ->
    entered = cxDiff @collection.models, @seen
    exited = cxDiff @seen, @collection.models
    @seen = _.reject @seen.concat(entered), (m1) ->
      _.some exited, (m2) -> m1.id is m2.id
    _.forEach entered, (model) =>
      card = @cards[model.id] ?= new MachineCard(model: model)
      card.render()
      unless card.$el.is ':visible'
        @$('.cards').append card.$el
        card.show()
    _.forEach exited, (model) =>
      card = @cards[model.id]
      card.hide()
    @$('.instructions').text if @collection.size()
      "Choose a machine to connect to."
    else
      "No machines found."
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
