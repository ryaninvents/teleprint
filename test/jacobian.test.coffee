J = require '../math/jacobian'

{expect} = require 'chai'

compareMatrices = (mat1, mat2, epsilon=1e-5) ->
  ['rows','cols'].forEach (x) ->
    expect(mat1.dimensions()[x]).to.equal(mat2.dimensions()[x])
  [1..mat1.dimensions().rows].forEach (i) ->
    [1..mat1.dimensions().cols].forEach (j) ->
      expect(mat1.e i, j).to.be.closeTo mat2.e(i,j), epsilon

describe 'Jacobian', ->
  it 'should derive J(f1 = (x^2)y, f2 = 5x*sin(y))', ->
    F = [
      (x, y) -> x*x*y
      (x, y) -> 5*x + Math.sin y
    ]
    expected = (x, y) ->
      $M [
        [ 2*x*y,        x*x ]
        [     5, Math.cos y ]
      ]
    JF = J(F)
    [0..10].forEach ->
      x = Math.random()*20-10
      y = Math.random()*20-10
      compareMatrices JF(x, y), expected(x, y)
  it 'should derive J(f1 = x, f2 = 5z, f3 = 4y^2 - 2z, f4 = z*sin(x))', ->
    F = [
      (x, y, z) -> x
      (x, y, z) -> 5*z
      (x, y, z) -> 4*y*y - 2*z
      (x, y, z) -> z*Math.sin(x)
    ]
    expected = (x, y, z) ->
      $M [
        [            1,     0,             0 ]
        [            0,     0,             5 ]
        [            0,   8*y,            -2 ]
        [z*Math.cos(x),     0,   Math.sin(x) ]
      ]
    JF = J(F)
    [0..10].forEach ->
      x = Math.random()*20-10
      y = Math.random()*20-10
      z = Math.random()*20-10
      compareMatrices JF(x, y, z), expected(x, y, z)
