THREE = require 'three'

Vec = THREE.Vector3

sq = (x) -> x*x

module.exports =
class Sphere
  constructor: (@radius=1, @center=new Vec(0,0,0)) ->
  toString: -> "Sphere(#{@radius}@[#{@center.x},#{@center.y},#{@center.z}])"
  @trilaterateFromPlane: (spheres) ->
    r = spheres.map (sphere) -> sphere.radius

    d = spheres[1].center.x
    i = spheres[2].center.x
    j = spheres[2].center.y

    x = ( sq(r[0]) - sq(r[1]) + sq(d) )/(2*d)
    y = ( sq(r[0]) - sq(r[2]) + sq(i) + sq(j) )/(2*j) - (i/j)*x
    z = Math.sqrt sq(r[0]) - sq(x) - sq(y)

    [z, -z]

  @trilaterate: (spheres) ->
    P = spheres.map (s) -> s.center
    r = spheres.map (s) -> s.radius

    basisX = new Vec().copy(P[1]).sub(P[0]).normalize()

    i = new Vec().copy(basisX).dot(new Vec().copy(P[2]).sub(P[0]))

    basisY = new Vec().copy(P[2]).sub(P[0]).sub(new Vec().copy(basisX).multiplyScalar(i)).normalize()
    basisZ = new Vec().crossVectors(basisX, basisY)

    d = (new Vec().copy(P[1]).sub(P[0])).length()
    j = (new Vec().copy(basisY)).dot( new Vec().copy(P[2]).sub(P[0]) )

    x = ( sq(r[0]) - sq(r[1]) + sq(d) )/(2*d)
    y = ( sq(r[0]) - sq(r[2]) + sq(i) + sq(j) ) / (2*j) - (i*x)/j
    z = Math.sqrt(sq(r[0]) - sq(x) - sq(y))

    woZ = new Vec().copy(P[0]).add(new Vec().copy(basisX).multiplyScalar(x)).add(new Vec().copy(basisY).multiplyScalar(y))
    [new Vec().copy(woZ).add(new Vec().copy(basisZ).multiplyScalar(z)), new Vec().copy(woZ).sub(new Vec().copy(basisZ).multiplyScalar(z))]
