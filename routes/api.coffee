express = require 'express'
module.exports = router = express.Router()

router.use '/ports', require './api/ports'
router.use '/connections', require './api/connections'
