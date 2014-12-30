serialPort = require 'serialport'
express = require 'express'
Machine = require '../../models/machine'
module.exports = router = express.Router()
_ = require 'lodash'
Bacon = require 'baconjs'

router.get '/', (req, res) ->
  machines = Machine.listVisible()
  machines = machines.filter (m) -> m.port?.get('pnpId') or m.get('pnpId')
    .map (m) -> m.toJSON()
  res.json machines

###
router.post '/:id/connect', (req, res) ->
  machineID = req.params.id
  Bacon.fromArray(Machine.listVisible().filter (m) -> m.get('uuid') is machineID)
    .flatMap (machine) ->
      console.log "Processing #{machine.get 'id'}"
      Bacon.fromNodeCallback(machine.port, 'open')
        .map -> machine
    .onValue (machine) ->
      machine.set 'active', yes
      console.log "Connected to machine", machine
      res.json machine.toJSON()
###
