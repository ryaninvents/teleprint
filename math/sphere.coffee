require 'sylvester'

{sq} = require './util'

module.exports =
class Sphere
  constructor: (@radius=1, @center=$V([0,0,0])) ->

  toString: -> "Sphere(#{@radius}@[#{@center.e(1)},#{@center.e(2)},#{@center.e(3)}])"

  # ##Sphere.trilaterate
  # Given three spheres, find the point(s) of intersection, if any.
  @trilaterate: (spheres) ->
    P = spheres.map (s) -> s.center
    r = spheres.map (s) -> s.radius

    basisX = P[1].subtract(P[0]).toUnitVector()

    i = basisX.dot(P[2].subtract(P[0]))

    basisY = P[2].subtract(P[0]).subtract(basisX.multiply(i)).toUnitVector()
    basisZ = basisX.cross(basisY)

    d = P[1].subtract(P[0]).modulus()
    j = basisY.dot(P[2].subtract(P[0]))

    x = ( sq(r[0]) - sq(r[1]) + sq(d) )/(2*d)
    y = ( sq(r[0]) - sq(r[2]) + sq(i) + sq(j) ) / (2*j) - (i*x)/j
    z2 = sq(r[0]) - sq(x) - sq(y)

    if z2 < 0
      []
    else if z2 is 0
      [P[0].add(basisX.multiply(x)).add(basisY.multiply(y))]
    else
      z = Math.sqrt z2
      woZ = P[0].add(basisX.multiply(x)).add(basisY.multiply(y))
      [woZ.add(basisZ.x(z)), woZ.subtract(basisZ.x(z))]
