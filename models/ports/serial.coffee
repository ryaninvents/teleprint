Bacon = require 'baconjs'
{SerialPort} = require 'serialport'

Port = require '../port'

# `ports` is an `Array{SerialPort}`
ports = new Port.Collection()

module.exports =
SerialPort = Port.extend
  initialize: ->
    comName = @get 'comName'
    baudrate = @get 'baudrate'
    opt =
      baudrate: baudrate
# Create the actual port we'll be talking to.
    @port = new SerialPort comName, opt, no
# Bind the port events so we get them on our model.
    ['open','close','data','error'].forEach (evName) =>
      @port.on evName, =>
        @trigger.apply @, _.flatten [evName, arguments]
  defaults: ->
    baudrate: 9600
  open: -> @port.open()
  close: -> @port.close()
  write: (data) ->
    @port.write data
    @trigger 'write', data
  flush: -> @port.flush()
,
  enumerate: -> ports
  type: -> "serial"
  longname: -> "Serial port"
  description: ->
    "A serial port connection."
