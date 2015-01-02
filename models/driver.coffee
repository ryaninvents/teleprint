Backbone = require 'backbone'
require('../backbone.eventstreams')(Backbone)

DRIVER_TYPES = ['sim','serial']

module.exports =
# # Class Driver
Driver = Backbone.Model.extend
# ### open()
  open: ->
    throw new Error "Driver::open() is abstract (must implement in subclass)"
# ### close()
  close: ->
    throw new Error "Driver::close() is abstract (must implement in subclass)"
# ### write()
  write: (message) ->
    throw new Error "Driver::write(message) is abstract (must implement in subclass)"
# ### flush()
  flush: () ->
    throw new Error "Driver::flush() is abstract (must implement in subclass)"
,
# ## Static methods
# ### Driver.types()
#
# List the types of driver available
  types: () ->
    DRIVER_TYPES.map (n) ->
      require "./drivers/#{n}"

# ### Driver.enumerate()
#
# Returns a `Driver.Collection` that will fire `add` and `remove` events
# as appropriate to signal that machines have become
# available/unavailable.
#
# This is an abstract method that must be overridden.
  enumerate: () ->
    throw new Error "Driver.enumerate() is abstract (must override in subclass)"

Driver.Collection = Backbone.Collection.extend
  model: Driver
