Backbone = require 'backbone'
require('../backbone.eventstreams')(Backbone)

PORT_TYPES = ['sim','serial']

module.exports =
# # Class Port
Port = Backbone.Model.extend
# ### open()
  open: ->
    throw new Error "Port::open() is abstract (must implement in subclass)"
# ### close()
  close: ->
    throw new Error "Port::close() is abstract (must implement in subclass)"
# ### write()
  write: (message) ->
    throw new Error "Port::write(message) is abstract (must implement in subclass)"
# ### flush()
  flush: () ->
    throw new Error "Port::flush() is abstract (must implement in subclass)"
,
# ## Static methods
# ### Port.types()
#
# List the types of port
  types: () ->
    PORT_TYPES.map (n) ->
      require "./ports/#{n}"

# ### Port.enumerate()
#
# Returns a `Port.Collection` that will fire `add` and `remove` events
# as appropriate to signal that machines have become 
# available/unavailable.
#
# This is an abstract method that must be overridden.
  enumerate: () ->
    throw new Error "Port.enumerate() is abstract (must override in subclass)"

Port.Collection = Backbone.Collection.extend
  model: Port
