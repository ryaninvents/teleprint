require 'sylvester'
_ = require 'lodash'

H = require '../sim/hessian'
d = require '../sim/derivative'

{expect} = require 'chai'

describe 'Hessian', ->
  before ->
    @f = (x, y) -> x*x + 2*x*y + 3*y*y + 4*x + 5*y + 6
    @Hf = H @f, delta: .01
  it 'should compute the Hessian matrix of x^2 + 2xy + 3y^2 + 4x + 5y + 6', ->
    expected = $M [
      [2, 2]
      [2, 6]
    ]
    [0..10].forEach =>
      x = Math.random()*100-50
      y = Math.random()*100-50
      actual = @Hf(x, y)
      [1..2].forEach (j) ->
        [1..2].forEach (i) ->
          a = actual.e i,j
          e = expected.e i,j
          expect(a).to.be.closeTo e, 1e-3
