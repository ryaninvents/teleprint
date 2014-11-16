Sphere = require '../sim/sphere'

require 'sylvester'

assert = require 'assert'
{expect} = require 'chai'

describe 'Sphere', ->
  it 'should trilaterate properly', ->
    s1 = new Sphere 1, $V [ 0,  0, 0]
    s2 = new Sphere 1, $V [ 1,  0, 0]
    s3 = new Sphere 1, $V [.5,  1, 0]
    intersections = Sphere.trilaterate [s1, s2, s3]
    [s1,s2,s3].forEach (sphere) ->
      intersections.forEach (intersection) ->
        expect(intersection.subtract(sphere.center).modulus()).to.be.closeTo sphere.radius, 1e-8
