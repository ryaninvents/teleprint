import {createStore, applyMiddleware} from 'redux';

import reducer from './reducer';
import {serialMiddleware} from '../networking/serial';

const middlewares = [
  serialMiddleware
];

const store = applyMiddleware(...middlewares)(createStore)(reducer);

export default store;

export const APP_INIT = Symbol('teleprint/app-init');

export function appInit(app) {
  return {
    type: APP_INIT,
    app
  };
}
