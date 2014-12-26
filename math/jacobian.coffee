require 'sylvester'

d = require './derivative'
del = require './del'

{vec2array} = require './util'

module.exports =
# Find the Jacobian of the given array (presumed a vertical vector)
# of functions.
#
# Returns a function that takes the same parameters as the input
# functions, and returns a matrix of the value of the Jacobian at that point.
Jacobian = (F, opt={}) ->
  derivatives = F.map (f) ->
    [0...(opt.length or f.length)].map (i) ->
      d(f).d(i, opt)
  () ->
    args = arguments
    $M derivatives.map (ff) ->
      vec2array(ff).map (f) ->
        f.apply null, args
