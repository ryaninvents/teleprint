newton = require '../math/newton'

{expect} = require 'chai'

describe 'Newton optimization', ->
  it 'should be able to find the vertex of a parabola', ->
    f = (x, y) -> (x-10)*(x-10) + (y-5)*(y-5)
    optimum = newton.optimize(f, initialGuess: [0.1,0.1], delta: .01)
    expected = [10, 5]
    expected.forEach (expected, i) ->
      expect(optimum[i]).to.be.closeTo expected, 1e-8
describe 'Newton root finder', ->
  it 'should be able to locate a root of a linear eqn', ->
    f = (x, y) -> x - y
    root = newton.findRoot f, initialGuess: [5,6]
  it 'should be able to locate a root of a slightly more complex eqn', ->
    f = (x, y) -> Math.sin(x) - Math.log(y)
    root = newton.findRoot f, initialGuess: [0, 2], gamma: 0.1
    expect(f.apply null, root).to.be.closeTo 0, 1e-3
