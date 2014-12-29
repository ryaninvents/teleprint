serialPort = require 'serialport'
express = require 'express'
Machine = require '../../entities/machine'
module.exports = router = express.Router()
_ = require 'lodash'

router.get '/', (req, res) ->
  connected = Machine.listConnected()
  connected.onError (err) ->
    res.status(500).json(err)
  connected.map((x)->[x]).fold([],'.concat').onValue (machines) ->
    machines = machines.filter (m) -> m.port?.pnpId
      .map (m) ->
        json = _.clone m.attributes
        json.port = m.port
        json.hasImage = Boolean json.hasImage
        json
    res.json machines
