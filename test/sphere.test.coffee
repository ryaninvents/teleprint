Sphere = require '../sim/sphere'

Vec = require('three').Vector3

assert = require 'assert'
{expect} = require 'chai'

describe 'Sphere', ->
  it 'should trilaterate properly', ->
    s1 = new Sphere 1, new Vec  0,  0, 0
    s2 = new Sphere 1, new Vec  1,  0, 0
    s3 = new Sphere 1, new Vec .5,  1, 0
    [i1, i2] = Sphere.trilaterate [s1, s2, s3]
    console.log i1, i2
    expect(new Vec().copy(i1).distanceTo(s1.center)).to.be.closeTo s1.radius, 1e-5
