d = require '../sim/derivative'

{expect} = require 'chai'

describe 'Derivative', ->
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
