import {createStore, applyMiddleware} from 'redux';

import reducer from './reducer';
import {serialMiddleware} from '../networking/serial';
import {wsServerMiddleware} from '../networking/wsServer';

import {APP_INIT} from '../main/mainActions';

const middlewares = [
  wsServerMiddleware,
  serialMiddleware
];

const store = applyMiddleware(...middlewares)(createStore)(reducer);

export default store;

export function appInit(app) {
  return {
    type: APP_INIT,
    app
  };
}
