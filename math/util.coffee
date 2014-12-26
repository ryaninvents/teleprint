STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/g
ARGUMENT_NAMES = /([^\s,]+)/g

_ = require 'lodash'

module.exports =
  sq: (x) -> x*x
  vec2array: (vec) ->
    return vec if _.isArray vec
    out = []
    vec.each (v) -> out.push v
    out
  getParamNames: (func) ->
    fnStr = func.toString().replace(STRIP_COMMENTS, "")
    result = fnStr.slice(fnStr.indexOf("(") + 1, fnStr.indexOf(")")).match(ARGUMENT_NAMES)
    if result is null
      []
    else
      result
