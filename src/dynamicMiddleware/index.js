import {compose} from 'redux';

export default const dynamicMiddleware = (middlewareVar='middleware') => store => next => {
  const middlewares = store.getState()[middlewareVar];
  if (!(middlewares && middlewares instanceof Array)) return next(action);
  const transformedMiddlewares = middlewares.map(middleware => middleware(store)).concat([next]);
  const f = compose(...transformedMiddlewares);
  return action => f(action);
}
