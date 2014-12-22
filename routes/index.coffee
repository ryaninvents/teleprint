express = require("express")
router = express.Router()
_ = require("lodash")

ip = _.flatten(_.values(require("os").networkInterfaces())).filter((iface) ->
  iface.family is "IPv4" and iface.address isnt "127.0.0.1"
).map((iface) ->
  iface.address
)[0]
console.log ip

# GET home page. 
router.get "/", (req, res) ->
  res.render "index",
    ip: ip

module.exports = router
