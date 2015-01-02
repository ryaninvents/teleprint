Bacon = require 'baconjs'
_ = require 'lodash'

serialPort = require 'serialport'
{SerialPort} = serialPort

Driver = require '../driver'

# `drivers` is an `Array{SerialPortDriver}`
drivers = new Driver.Collection()

module.exports =
SerialPortDriver = Driver.extend
  initialize: ->
    comName = @get 'comName'
    baudrate = @get 'baudrate'
    opt =
      baudrate: baudrate
# Create the actual port we'll be talking to.
    @port = new SerialPort comName, opt, no
    @port.on 'open', => @trigger 'open'
    @port.on 'close', => @trigger 'close'
    @port.on 'data', (d) => @trigger 'data', d.toString()
    @port.on 'error', (e) => @trigger 'error', e

  defaults: -> SerialPortDriver.options()

  open: -> @port.open()

  close: -> @port.close()

  write: (data) ->
    @port.write data
    @trigger 'write', data

  flush: -> @port.flush()
,
  enumerate: -> drivers
  type: -> "serial"
  longname: -> "Serial port"
  description: ->
    "A serial port connection."
  options: ->
    baudrate: 115200

updatePorts = () ->
  serialPort.list (err, portList) ->
# Add each new port that we find to `drivers`.
    portList.forEach (port) ->
      return unless port.pnpId
      unless p = drivers.filter((p) -> p.get('comName') is port.comName)[0]
        drivers.add new SerialPortDriver port
# For every port in `drivers` but not our list, remove from `drivers`.
# This means something's been unplugged.
    drivers.forEach (driver) ->
      if p = portList.filter((p) -> driver.get('comName') is p.comName)[0]
        return
      driver.destroy()
# Do it again.
    setTimeout updatePorts, 1000

updatePorts()
