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

  it "should optimize a printer's calibration", ->
    console.log @bot.toString()
    solution = @bot.solveGivenLocationAndHeightError
      location: $V [0, 85, 0]
      heightError: -1.905
    console.log solution.toString()
