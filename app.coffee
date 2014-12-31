express = require("express")
path = require("path")
favicon = require("static-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
routes = require("./routes/index")
browserify = require 'browserify-middleware'
api = require './routes/api'
opts = require './options'
app = express()

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use favicon()
app.use logger("dev")
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()

coffeeify = require 'coffeeify'
jadeify = require 'jadeify'
browserify.settings 'transform', [coffeeify, jadeify]
app.use '/js/main.js', browserify './public/js/main.coffee'

app.use express.static(path.join(__dirname, "public"))
app.use express.static(path.join(__dirname, "bower_components"))

app.use '/api', api
app.use "/", routes

#/ catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err

#/ error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}

module.exports = (callback) ->
  port = opts.port
  address = opts.address
  server = require('http').Server(app)
  require('./routes/socket')(server)
  server.listen port, address, => console.log "Listening on #{address}:#{port}"
