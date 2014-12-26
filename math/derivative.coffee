_ = require 'lodash'

{getParamNames} = require './util'

d = (func) ->
  params = getParamNames(func)
  d: (param, opt={}) ->
    if _.isString param
      param = _.indexOf(params, param)
    unless (0 <= param)
      throw new Error "`param` must be the name of an argument of `func`, or a numerical index (was #{param})"
    N = opt.length ? func.length
    delta = opt.delta or 1e-5
    symmetric = opt.symmetric
    symmetric ?= yes
    funcWithDelta = (delta) -> () ->
      newArgs = _(arguments).map((arg, i) ->
        if i is param
          arg + delta
        else
          arg
      ).valueOf()
      func.apply(null, newArgs)
    f1 = if symmetric
      funcWithDelta(delta/2)
    else
      funcWithDelta(delta)
    f0 = if symmetric
      funcWithDelta(-delta/2)
    else
      funcWithDelta(0)
    f = () ->
      (f1.apply(null, arguments) - f0.apply(null, arguments)) / delta
    f.length = N
    f

module.exports = d
