require 'sylvester'

H = require './hessian'
d = require './derivative'
del = require './del'

vec2array = (vec) ->
  out = []
  vec.each (v) -> out.push v
  out

# #Newton optimization
module.exports =
newton = (f, opt={}) ->
  X_n = opt.initialGuess ? (throw new Error('Must pass initialGuess into opt'))
  epsilon = opt.epsilon or 1e-6
  delta = opt.delta or 1e-3
  iterations = opt.maxIterations or 100
  gamma = opt.gamma or 1
  Hf = H(f, opt)
  del_f = del(f, opt)
  v_n = f.apply null, X_n
  X_n = $V X_n
  while iterations--> 0
    X_n1 = X_n.subtract(
      Hf.apply(null, vec2array X_n).inverse()
      .multiply(gamma)
      .multiply(del_f.apply null, vec2array X_n)
    )
    v_n1 = f.apply null, vec2array X_n1
    diff = Math.abs v_n1 - v_n
    if diff < epsilon
      break
    v_n = v_n1
    X_n = X_n1
  return vec2array X_n1
