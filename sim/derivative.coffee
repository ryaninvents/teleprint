_ = require 'lodash'

STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/g
ARGUMENT_NAMES = /([^\s,]+)/g

getParamNames = (func) ->
  fnStr = func.toString().replace(STRIP_COMMENTS, "")
  result = fnStr.slice(fnStr.indexOf("(") + 1, fnStr.indexOf(")")).match(ARGUMENT_NAMES)
  if result is null
    []
  else
    result

d = (func) ->
  params = getParamNames(func)
  unless params.length
    throw new Error '`func` must be dependent on at least one variable'
  d: (param, opt={}) ->
    if _.isString param
      param = _.indexOf(params, param)
    unless 0 <= param < params.length
      throw new Error '`param` must be the name of an argument of `func`, or a numerical index'
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
    return () ->
      (f1.apply(null, arguments) - f0.apply(null, arguments)) / delta

module.exports = d
