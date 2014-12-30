serialPort = require 'serialport'
{SerialPort} = serialPort
uuid = require 'node-uuid'
Bacon = require 'baconjs'

ports = []

serial = (data, callback) ->
  {comName, baudRate} = data
  baudRate ?= 9600
  port = new SerialPort comName, baudRate: baudRate, (err) ->
    if err then return callback err
    port.info =
      id: uuid.v4()
      comName: comName
      baudRate: baudRate
      opened: +new Date()
      type: 'serial'
    port.type = 'serial'
    port.getReadStream = ->
      Bacon.fromEventTarget port, 'data'
    callback null, port

serial.list = (callback) ->
  callback null, ports

getPorts = (callback) ->
  serialPort.list (err, ports) ->
    if err
      callback err
    else
      callback null, ports.map (p) ->
        p.type = 'serial'; p

serial.listStream = Bacon.interval(500)
  .flatMap -> Bacon.fromNodeCallback getPorts

serial.enters = serial.listStream
  .filter (m) ->

module.exports = serial
