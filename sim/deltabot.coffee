THREE = require 'three'
_ = require 'lodash'

Vec = THREE.Vector3

Sphere = require './sphere'

sq = (x) -> x*x

class DeltaBot
  constructor: (params) ->
    {
      @armLength
      @platformOffset
      @bedRadius
    } = params
  towerLocations: (opt={})->
    v = new Vec()
    # If we pass the carriageAdjusted option, then
    # move the towers inward so we can compute heights
    # based on effective radius.
    adjustment = if opt?.carriageAdjusted then @platformOffset else 0
    r = @bedRadius - adjustment
    Vec.apply v, [0..2].map (i) ->
      angle = 2*i*Math.PI/3
      [Math.sin(angle), Math.cos(angle), 0].map (x) -> r*x
  carriageHeights: (pos) ->
    ABC = @towerLocations(carriageAdjusted: yes)
    W = pos
    W_ = W.copy().setZ(0)
    r = @armLength
    horizontalDistance = ABC.map (tower) ->
      tower.copy().setZ(0).distanceTo W_
    horizontalDistance.map (dist) ->
      W.z + Math.sqrt sq(r) - sq(dist)
  printHeadLocation: (carriages) ->
    towers = @towerLocations(carriageAdjusted: yes)
    r = @armLength
    spheres = _.zip(towers, carriages).map (x) ->
      tower = x[0]
      carriageZ = x[1]
      new Sphere r, tower.copy().add(new Vec(0,0,carriageZ))
    Sphere.trilaterate(spheres)
