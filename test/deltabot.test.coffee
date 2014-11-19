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
    @bot2 = new DeltaBot
      armLength: 251
      platformOffset: 18+33
      bedRadius: 175

  it 'should offset tower locations by the carriage amount', ->
    expectedLength = @bot.bedRadius - @bot.platformOffset
    @bot.towerLocations(carriageAdjusted: yes).forEach (loc) =>
      expect(loc.modulus()).to.be.closeTo expectedLength, 1e-8

  it 'should give negligible height error when a bot is compared vs self', ->
    err = @bot.heightErrorAtLocation @bot, $V [0, 85, 0]
    expect(err).to.be.closeTo 0, 1e-5

  it 'should compute height error at a given location', ->
    err = @bot.heightErrorAtLocation @bot2, $V [0, 85, 0]
    expect(_.isNumber err).to.be.ok()

  it 'should determine a perfectly-calibrated printer to be optimal', ->
    pt = $V [0, 85, 0]
    recoveredBot = @bot.solveGivenLocationAndHeightError
      location: pt
      heightError: 0
      epsilon: 1e-5

    console.log @bot.toString()
    console.log recoveredBot.toString()

    expect(recoveredBot.armLength).to.be.closeTo @bot.armLength, 1e-5
    expect(recoveredBot.bedRadius).to.be.closeTo @bot.bedRadius, 1e-5

  it 'should recover a slightly-off printer calibration', ->
    pt = $V [0, 85, 0]
    err = @bot.heightErrorAtLocation @bot2, pt
    recoveredBot = @bot.solveGivenLocationAndHeightError
      location: pt
      heightError: err
      epsilon: 1e-5
      gamma: 0.1
      iterations: 1e4

    console.log @bot2.toString()
    console.log recoveredBot.toString()

    expect(recoveredBot.armLength).to.be.closeTo @bot2.armLength, 1e-5
    expect(recoveredBot.bedRadius - recoveredBot.platformOffset)
    .to.be.closeTo @bot2.bedRadius - @bot2.platformOffset, 1e-5

  it "should optimize a printer's calibration", ->
    console.log @bot.toString()
    solution = @bot.solveGivenLocationAndHeightError
      location: $V [0, 85, 0]
      heightError: 0
      gamma: 1
    console.log solution.toString()
