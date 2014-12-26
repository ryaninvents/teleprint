require 'sylvester'

{getParamNames} = require './util'
d = require './derivative'

# Create a unit vector in `N` dimensions pointing along the `i`th axis.
#
# Keep in mind when using this that `N` is a count and `i` is a 0-based index.
unit = (N, i) ->
  $V [0..N].map (x, j) ->
    if j is i then 1 else 0

# # Del

# The gradient operator.
del = (func, opt={}) ->

  # First calculate partial derivatives against all dimensions of the function.
  derivatives = [0...func.length].map (i) -> d(func).d(i, opt)

  # Store the number of dimensions for later.
  N = derivatives.length

  # Here's the function we return. Its domain is identical to that of `f`,
  # and it returns a vector with the value of the partial derivative in every
  # dimension at the passed point times the unit vector for that dimension.
  # See [Wikipedia's Gradient article](https://en.wikipedia.org/wiki/Gradient)
  # for details.
  () ->
    args = arguments
    $V derivatives.map (f, i) ->
      f.apply(null, args)

del.unit = unit

module.exports = del
