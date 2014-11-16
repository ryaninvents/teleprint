d = require '../sim/derivative'

{expect} = require 'chai'

describe 'Derivative', ->
  before ->
    @f = (x, y) -> x*x + 2*x*y + 3*y*y + 4*x + 5*y + 6
  it 'should take the derivative of x^2 + 2xy + 3y^2 + 4x + 5y + 6 wrt x', ->
    df_dx = d(@f).d(0)
    expectedDerivative = (x, y) -> 2*x + 2*y + 4
    [0..10].forEach =>
      x = Math.random()*100-50
      y = Math.random()*100-50
      actual = df_dx x,y
      expected = expectedDerivative x,y
      expect(actual).to.be.closeTo expected, 1e-6
  it 'should take the second derivative correctly wrt x', ->
    df_dx = d(@f).d(0, delta: .01)
    d2f_dx2 = d(df_dx, length:2).d(1, delta: .01)
    [0..10].forEach =>
      x = Math.random()*100-50
      y = Math.random()*100-50
      actual = d2f_dx2 x,y
      expected = 2
      expect(actual).to.be.closeTo expected, 1e-5
  it 'should differentiate by x and then y', ->
    df_dx = d(@f).d(0, delta: .01)
    d2f_dx2 = d(df_dx, length:2).d(0, delta: .01)
  it 'should take the derivative of (x) -> x*x', ->
    f = (x) -> x*x
    df_dx = d(f).d('x')
    expect(df_dx(0)).to.be.closeTo 0, 1e-6
    expect(df_dx(5)).to.be.closeTo 10, 1e-6
  it 'should take the derivative of (x) -> sin(x)', ->
    f = (x) -> Math.sin x
    df_dx = d(f).d('x')
    expect(df_dx(0)).to.be.closeTo 1, 1e-6
  it 'should take the partial derivative of (x,y) -> sin(x) + cos(y) w.r.t. x', ->
    f = (x,y) -> Math.sin(x) + Math.cos(y)
    df_dx = d(f).d('x')
    expect(df_dx(0,0)).to.be.closeTo 1, 1e-6
  it 'should take the partial derivative of (x,y) -> x^2 - y^2 + 3xy w.r.t. y', ->
    f = (x, y) -> x*x - y*y + 3*x*y
    df_dy = d(f).d('y')
    expect(df_dy( 0, 0)).to.be.closeTo 0, 1e-6
    expect(df_dy( 4, 7)).to.be.closeTo -2, 1e-6
    expect(df_dy(-6, 2)).to.be.closeTo -22, 1e-6
