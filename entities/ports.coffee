Bacon = require 'baconjs'
_ = require 'lodash'

portTypes =
  serial: 'serialPort'
  sim: 'sim'

ports = _.mapValues portTypes, (moduleName) ->
  require "./ports/#{moduleName}"

ports.list = (callback) ->
  stream = Bacon.fromArray _.keys portTypes
    .flatMap (key) ->
      Bacon.fromNodeCallback ports[key], 'list'
  if callback?
    stream.reduce([], '.push').onValue callback
  else
    stream.flatMap (x) -> console.log x; Bacon.fromArray x

module.exports = ports
