DeltaBot = require '../math/deltabot'

require 'sylvester'

{expect} = require 'chai'
_ = require 'lodash'

describe 'DeltaBot', ->

  beforeEach ->
    # Our "ideal" DeltaBot.
    @bot = new DeltaBot
      armLength: 250
      bedRadius: 157
    # Our "actual" DeltaBot.
    @bot2 = new DeltaBot
      armLength: 249
      bedRadius: 157

  it 'should give negligible height error when a bot is compared vs self', ->
    err = @bot.heightErrorAtLocation @bot, $V [0, 85, 0]
    expect(err).to.be.closeTo 0, 1e-5

  it 'should compute height error at a given location', ->
    err = @bot.heightErrorAtLocation @bot2, $V [0, 85, 0]
    expect(_.isNumber err).to.be.ok()

  it 'should compute carriage locations at an arm\'s length from print head', ->
    testCarriageHeightsAt = (location) =>
      ch = @bot.carriageHeights location
      tl = @bot.towerLocations(carriageAdjusted: yes)
      carriages = ch.map (c, i) ->
        $V [tl[i].e(1), tl[i].e(2), c]
      carriages.forEach (carriage) =>
        expect(carriage.subtract(location).modulus()).to.be.closeTo @bot.armLength, 1e-6
    testCarriageHeightsAt $V [0,0,0]

  ###
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
  ###

  it 'should recover a slightly-off printer calibration', ->
    pts = [0...6].map (n) ->
      $V [
        85*Math.cos(Math.PI*n/3)
        85*Math.sin(Math.PI*n/3)
        0
      ]
    pts = pts.map (pt) => [pt, @bot2.amountOutOfPlaneAtLocation(@bot, pt)]

    recoveredBot = @bot.solveGivenLocationsAndHeightErrors pts,
      epsilon: 1e-4
      gamma: 0.1
      iterations: 1e4
      delta: 0.01

    [0..10].forEach =>
      pt = $V [
        Math.random()*100-50
        Math.random()*100-50
        0
      ]
      err = @bot2.amountOutOfPlaneAtLocation recoveredBot, pt
      expect(err).to.be.closeTo 0, 0.2
    #expect(recoveredBot.armLength).to.be.closeTo(@bot2.armLength, 1e-5)
    #expect(recoveredBot.bedRadius).to.be.closeTo(@bot2.bedRadius, 1e-5)
