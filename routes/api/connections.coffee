express = require 'express'
module.exports = router = express.Router()
connections = require '../../entities/connections'

router.get '/', (req, res) ->
  res.json connections.map (cx) -> cx.info

router.post '/', (req, res) ->
  {comName, baudRate} = req.body

  unless comName?
    return res.status(400).json(error: "comName field required")

  if connections.any((cx) -> cx.info.comName is comName)
    return res.status(400).json(error: "port already open")

  connections.add req.body, (err, port) ->
    if err
      console.error err, err.toString()
      return res.status(500).json
        error: "problem opening port"
        message: err.toString()
        details: err
    res.json port.info

