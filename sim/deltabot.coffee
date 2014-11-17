_ = require 'lodash'
require 'sylvester'

Sphere = require './sphere'

{sq} = require './util'

slope = (f, x, delta=0.001) -> (f(x+delta) - f(x))/delta

newton = require './newton'

module.exports =
class DeltaBot
  constructor: (params) ->
    {
      @armLength
      @platformOffset
      @bedRadius
    } = params
  toString: -> "DeltaBot(#{@armLength} arms/ #{@bedRadius} radius/ #{@platformOffset} offset)"
  towerLocations: (opt={})->
    # If we pass the carriageAdjusted option, then
    # move the towers inward so we can compute heights
    # based on effective radius.
    adjustment = if opt?.carriageAdjusted then @platformOffset else 0
    r = @bedRadius - adjustment
    [0..2].map (i) ->
      angle = 2*i*Math.PI/3
      $V([Math.sin(angle), Math.cos(angle), 0].map (x) -> r*x)
  carriageHeights: (pos) ->
    ABC = @towerLocations(carriageAdjusted: yes)
    W = pos
    W_ = W.map (x, i) -> if i is 3 then 0 else x
    r = @armLength
    horizontalDistance = ABC.map (tower) ->
      tower.map((x,i) -> if i is 3 then 0 else x).subtract(W_).modulus()
    horizontalDistance.map (dist) ->
      W.e(3) + Math.sqrt sq(r) - sq(dist)
  printHeadLocation: (carriages) ->
    towers = @towerLocations(carriageAdjusted: yes)
    r = @armLength
    spheres = _.zip(towers, carriages).map (x) ->
      tower = x[0]
      carriageZ = x[1]
      new Sphere r, tower.add($V([0,0,carriageZ]))
    Sphere.trilaterate(spheres)
  # Computes the height error at a given location.
  # The way this works is a little confusing; for example,
  # if you call
  #
  # ```
  # printer.heightErrorAtLocation(est, loc)
  # ```
  # then `printer` represents the parameters that are stored
  # in the printer's calibration (initially, the ideal params),
  # `est` represents the parameters that we're testing (the ones
  # that, if they turn out to be correct, will be loaded into the
  # printer), and `loc` is the location to test.
  #
  # If you don't get it, don't worry. You probably won't have to touch
  # this for most purposes.
  heightErrorAtLocation: (estBot, loc) ->

    # These are the carriage heights that get sent out to the motors.
    carriageHeights = @carriageHeights loc

    # If we take these carriage heights and pass them into a printer with
    # slightly different dimensions, then we'll get a slightly different
    # print head location.
    actualLocation = estBot.printHeadLocation carriageHeights

    # If we've got multiple locations...
    if actualLocation.length > 1
      #...pick the one with smallest Z.
      actualLocation = actualLocation.reduce (a,b) ->
        if a.e(3) < b.e(3) then a else b
    # If we've got one location...
    else if actualLocation.length is 1
      #... just use that one.
      actualLocation = actualLocation[0]
    else
      # If there are no locations, then that means that the machine would be
      # overconstrained and we want to return infinite error here.
      return Infinity

    # Return the difference in Z.
    actualLocation.subtract(loc).e 3

  solveGivenLocationAndHeightError: (opt={}) ->
    location = opt.location ? throw new Error 'need to pass a location'
    heightError = opt.heightError ? throw new Error 'need to pass a heightError'
    self = @
    # can't bind within functions that get passed to the optimizer
    f = (armLength, towerRadius) ->
      testBot = new DeltaBot
        armLength: armLength
        platformOffset: 0
        bedRadius: towerRadius
      z = self.heightErrorAtLocation(testBot, location) - heightError
      z*z
    optimum = newton f,
      initialGuess: [@armLength, @bedRadius - @platformOffset],
      delta: (opt.delta ? .001)
    new DeltaBot
      armLength: optimum[0]
      platformOffset: @platformOffset
      bedRadius: optimum[1] - @platformOffset
