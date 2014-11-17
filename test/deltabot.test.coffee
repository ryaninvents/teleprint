DeltaBot = require '../sim/deltabot'

require 'sylvester'

{expect} = require 'chai'
_ = require 'lodash'

describe 'DeltaBot', ->

  beforeEach ->
    @bot = new DeltaBot
      armLength: 250
      platformOffset: 18+33
      bedRadius: 175

  it 'should offset tower locations by the carriage amount', ->
    expectedLength = @bot.bedRadius - @bot.platformOffset
    @bot.towerLocations(carriageAdjusted: yes).forEach (loc) =>
      expect(loc.modulus()).to.be.closeTo expectedLength, 1e-8

  it 'should compute height error at a given location', ->
    bot2 = new DeltaBot
      armLength: 251
      platformOffset: 18+31
      bedRadius: 160
    err = @bot.heightErrorAtLocation bot2, $V [0, 85, 0]
    expect(_.isNumber err).to.be.ok()

describe 'Newtonian estimation', ->
  it 'should estimate sqrt(2)', ->
    f = (x) -> x*x - 2
    x = DeltaBot.newton(f, initialGuess: 10)
    expect(x).to.be.closeTo Math.sqrt(2), 1e-6
  it 'should solve sin(x)+log(x) = 2', ->
    f = (x) -> Math.sin(x) + Math.log(x) - 2
    x = DeltaBot.newton(f, initialGuess: 10)
    expect(x).to.be.closeTo 9.70042510714, 1e-6
