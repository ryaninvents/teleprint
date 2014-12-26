require 'sylvester'
_ = require 'lodash'

d = require './derivative'

# Don't worry about performance on the first pass.
# Worry about correctness.
H = (func, opt={}) ->

  # Number of arguments the original function accepts.
  # The return matrix will have size NxN.
  N = opt.length ? func.length

  op2 = _.clone opt
  op2.length = N

  funx = [0...N].map (rowIdx) ->
    [0...N].map (colIdx) ->
      df_di = d(func).d(rowIdx, op2)
      d2f_didj = d(df_di).d(colIdx, op2)

  ->
    args = arguments
    $M funx.map (row) ->
      row.map (d2f_didj) ->
        d2f_didj.apply null, args


module.exports = H
