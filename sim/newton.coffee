require 'sylvester'

H = require './hessian'
d = require './derivative'
del = require './del'

vec2array = (vec) ->
  out = []
  vec.each (v) -> out.push v
  out

# #Newton's methods
module.exports =
newton =

  # Find a root of a function close to the given starting point.
  findRoot: (f, opt={}) ->
    # Initial guess (required).
    X_n = opt.initialGuess ? (throw new Error('Must pass initialGuess into opt'))
    epsilon = opt.epsilon or 1e-6
    if _.isNumber(epsilon)
      epsilon = X_n.map -> epsilon
    delta = opt.delta or 1e-3
    if _.isNumber delta
      delta = X_n.map -> delta
    iterations = opt.maxIterations or 100
    gamma = opt.gamma or 1

    # Compute the gradient.
    del_f = del(f, opt)

    f_of_X_n1 = Infinity

    while iterations--> 0
      # First compute f(X_n) and f'(X_n)
      f_of_X_n = f.apply(null, vec2array X_n)
      f_prime_of_X_n = del_f.apply(null, vec2array X_n)

      # Then perform elementwise division of the output of f(X_n) (which is scalar)
      # over the gradient and subtract from X_n
      X_n1 = X_n.subtract f_prime_of_X_n.map (f_prime) -> f_of_X_n / f_prime

      # Find out how much we moved
      diff = vec2array X_n1.subtract(X_n)

    return vec2array X_n1

  optimize: (f, opt={}) ->
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
