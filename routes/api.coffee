express = require 'express'
module.exports = router = express.Router()

router.use '/machines', require './api/machines'
router.use '/connections', require './api/connections'
