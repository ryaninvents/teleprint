STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/g
ARGUMENT_NAMES = /([^\s,]+)/g

module.exports =
  sq: (x) -> x*x
  getParamNames: (func) ->
    fnStr = func.toString().replace(STRIP_COMMENTS, "")
    result = fnStr.slice(fnStr.indexOf("(") + 1, fnStr.indexOf(")")).match(ARGUMENT_NAMES)
    if result is null
      []
    else
      result
