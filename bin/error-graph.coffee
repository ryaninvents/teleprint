DeltaBot = require '../sim/deltabot'

require 'sylvester'

idealBot = new DeltaBot
  armLength: 250
  bedRadius: 175
  platformOffset: 18+33

actualBot = new DeltaBot
  armLength: 251
  bedRadius: 174
  platformOffset: idealBot.platformOffset

pt = $V [0, 85, 0]

[-90..90].forEach (x) ->
  console.log "#{x}\t#{idealBot.heightErrorAtLocation actualBot, $V([x,0,0])}"
