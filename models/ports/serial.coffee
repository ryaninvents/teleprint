Bacon = require 'baconjs'
_ = require 'lodash'

serialPort = require 'serialport'
SerialPortHandler = serialPort.SerialPort

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
    @port = new SerialPortHandler comName, opt, no
    @port.on 'open', => @trigger 'open'
    @port.on 'close', => @trigger 'close'
    @port.on 'data', (d) => @trigger 'data', d.toString()
    @port.on 'error', (e) => @trigger 'error', e

  defaults: -> SerialPort.options()

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
  options: ->
    baudrate: 115200

updatePorts = () ->
  serialPort.list (err, portList) ->
# Add each new port that we find to `ports`.
    portList.forEach (port) ->
      return unless port.pnpId
      unless p = ports.filter((p) -> p.get('comName') is port.comName)[0]
        ports.add new SerialPort port
# For every port in `ports` but not our list, remove from `ports`.
# This means something's been unplugged.
    ports.forEach (port) ->
      if p = portList.filter((p) -> port.get('comName') is p.comName)[0]
        return
      port.destroy()
# Do it again.
    setTimeout updatePorts, 1000

updatePorts()
