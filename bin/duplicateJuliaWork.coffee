require 'sylvester'

DeltaBot = require '../sim/deltabot'

myBotConfig = new DeltaBot
  armLength: 0.25
  platformOffset: 0.033
  bedRadius: 0.157

origin = $V [0, 0, 0]

console.log myBotConfig.carriageHeights origin
