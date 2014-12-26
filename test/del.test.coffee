del = require '../math/del'

{expect} = require 'chai'

describe 'Gradient', ->
  it 'should compute the gradient of 2x + 3y^2 + sin z', ->
    f = (x, y, z) -> 2*x + 3*y*y - Math.sin(z)
    i = del.unit 3, 0
    j = del.unit 3, 1
    k = del.unit 3, 2
    answer = (x, y, z) ->
      i.x(2).add(
        j.x(6*y)
      ).add(
        k.x(-Math.cos z)
      )
    gradient = del f
    checkAnswer = (x, y, z, actual) ->
      expected = answer x, y, z
      expected.each (n, i) ->
        if n is 0 then return
        expect(n).to.be.closeTo actual.e(i), 1e-6
    [0..10].forEach ->
      x = Math.random()*10
      y = Math.random()*10
      z = Math.random()*10
      checkAnswer x, y, z, gradient(x, y, z)
