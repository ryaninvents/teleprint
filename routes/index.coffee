express = require("express")
router = express.Router()
_ = require("lodash")

ip = _.flatten(_.values(require("os").networkInterfaces())).filter((iface) ->
  iface.family is "IPv4" and iface.address isnt "127.0.0.1"
).map((iface) ->
  iface.address
)[0]

# Match all routes except our static files we want to serve.
router.get /^(?!\/?(js|css|tpl|socket)).*$/, (req, res) ->
  res.render "index",
    ip: ip

module.exports = router
