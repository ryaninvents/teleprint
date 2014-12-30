Backbone = require 'backbone'
_ = require 'lodash'

tpl = require '../../tpl/MachineControls.jade'

module.exports =
MachineControls = Backbone.View.extend
  render: ->
    @$el.html tpl machine: @model
    @
