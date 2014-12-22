_ = require 'lodash'
require 'sylvester'

# We're using spheres to represent the deltabot arms. The center
# of the sphere is at the carriage, and the radius of the sphere
# is equal to the arm length. This way, the print head's location
# is simply at the intersection of the three spheres.
Sphere = require './sphere'

# Newton approximation.
newton = require './newton'

# Utility squaring function
sq = (x) -> x*x

# Slope at a point.
# TODO: probably get rid of this since now there's `derivative.coffee`
slope = (f, x, delta=0.001) -> (f(x+delta) - f(x))/delta


# Project two 3D points onto a plane, and find the distance between them
# without taking Z into account.
horizontalDistance = (A, B) ->
  Math.sqrt Math.pow(A.e(1)-B.e(1), 2) + Math.pow(A.e(2)-B.e(2), 2)

module.exports =
# # DeltaBot

# Represents a 3-tower, linear-actuator deltabot.
class DeltaBot
  constructor: (params) ->
    {
      @armLength
      @bedRadius
    } = params

  toString: -> "DeltaBot(#{@armLength}mm arms/ #{@bedRadius}mm radius)"

  # ## Tower locations

  # Get a list of points, where each point represents the location
  # of the base of a tower.
  towerLocations: (opt={})->
    r = @bedRadius
    [0..2].map (i) ->
      angle = 2*i*Math.PI/3
      $V([Math.sin(angle), Math.cos(angle), 0].map (x) -> r*x)

  # ## Carriage heights

  # Find carriage heights required for a given print head position.
  carriageHeights: (printHeadPosition) ->
    towers = @towerLocations()
    r = @armLength
    horizontalDistances = towers.map (tower) -> horizontalDistance tower, printHeadPosition
    horizontalDistances.map (d) ->
      printHeadPosition.e(3) + Math.sqrt(sq(r) - sq(d))

  # ## Print head location

  # Find possible print head positions for a given set of carriage
  # heights. This will return an array of 0, 1, or 2 positions
  # depending on how many possible solutions there are.
  #
  # `carriages` is an array of carriage heights.
  printHeadLocation: (carriages) ->
    towers = @towerLocations(carriageAdjusted: yes)
    r = @armLength

    # Map the towers and carriage heights together to
    # get a sphere modeling the possible endpoint positions
    # of each arm.
    spheres = _.zip(towers, carriages).map (x) ->
      [tower, carriageZ] = x
      new Sphere r, tower.add($V([0,0,carriageZ]))

    # Solve for the possible locations of the print head
    # by intersecting the possible positions of the arms.
    Sphere.trilaterate(spheres)

  # ## Height error at location

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
    # print head location. Here's where the print head actually ends up.
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

    # Return the Z-difference.
    actualLocation.e(3) - loc.e(3)

  # ## Amount out-of-plane at location

  # Figures out how far out-of-plane the print head movement is
  # at a particular location compared to center. In other words,
  # if you told the bot to move from the center to `loc` while
  # keeping constant Z, this function would figure out the actual
  # difference in Z.
  #
  # If this value is positive, then the print head moves in a
  # "bowl" shape; if negative, then the print head moves in
  # a "dome" shape.
  amountOutOfPlaneAtLocation: (estBot, loc) ->
    errorAtCenter = @heightErrorAtLocation estBot, $V [0,0,0]
    errorAtLoc = @heightErrorAtLocation estBot, loc
    errorAtLoc - errorAtCenter

  # ## Solve given locations and height errors

  # This will attempt to "solve" a deltabot, given an array of print head locations and
  # their associated errors; e.g. `[ [point, error], [point2, error2], ...]`.
  #
  # Options:
  # * `delta`: distance in domain to use for taking slope
  # * `epsilon`: smallest change in output we care about; if the error is
  #   smaller than this amount then we'll stop iterating
  solveGivenLocationsAndHeightErrors: (locErrorPairs, opt={}) ->

    # Here's the function we're going to optimize on.
    f = (armLength, towerRadius) =>

      # Create a candidate DeltaBot.
      testBot = new DeltaBot
        armLength: armLength
        bedRadius: towerRadius

      # For each test point and associated error...
      locErrorPairs.reduce (sum, pair) =>
        [point, err] = pair
        # ...add the difference between (the amount this point is
        # out-of-plane) and (the measured error at this point)
        sum + @amountOutOfPlaneAtLocation(testBot, point) - err
      , 0
    optimum = newton.findRoot f,
      initialGuess: [@armLength, @bedRadius],
      delta: (opt.delta ? .001)
      epsilon: (opt.epsilon ? 1e-5)
      gamma: opt.gamma ? 1
      iterations: opt.iterations
    new DeltaBot
      armLength: optimum[0]
      bedRadius: optimum[1]
