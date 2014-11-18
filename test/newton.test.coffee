newton = require '../sim/newton'

{expect} = require 'chai'

describe 'Newton optimization', ->
  it 'should be able to find the vertex of a parabola', ->
    f = (x, y) -> (x-10)*(x-10) + (y-5)*(y-5)
    optimum = newton.optimize(f, initialGuess: [0.1,0.1], delta: .01)
    expected = [10, 5]
    [0..1].forEach (i) ->
      expect(optimum[i]).to.be.closeTo expected[i], 1e-8
