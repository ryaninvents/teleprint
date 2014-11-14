DeltaBot = require '../sim/deltabot'

Vec = require('three').Vector3

{expect} = require 'chai'

describe 'DeltaBot', ->
  beforeEach ->
    @bot = new DeltaBot
      armLength: 250
      platformOffset: 18+33
      bedRadius: 175
  it 'should offset tower locations by the carriage amount', ->
    expectedLength = @bot.bedRadius - @bot.platformOffset
    @bot.towerLocations(carriageAdjusted: yes).forEach (loc) =>
      expect(new Vec().copy(loc).length()).to.be.closeTo expectedLength, 1e-8
