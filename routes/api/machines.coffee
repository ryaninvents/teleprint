serialPort = require 'serialport'
express = require 'express'
module.exports = router = express.Router()

router.get '/', (req, res) ->
  serialPort.list (err, ports) ->
    if err then return res.status(500).json(err)
    res.json ports

