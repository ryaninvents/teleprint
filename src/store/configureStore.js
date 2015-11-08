/* global __DEVTOOLS__ */
import { createStore, applyMiddleware, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import promiseMiddleware from 'redux-promise';
import createLogger from 'redux-logger';
import rootReducer from '../reducers';
import {wsClientMiddleware} from '../networking/wsClient';


const loggerMiddleware = createLogger({
  level: 'info',
  collapsed: true
});


let createStoreWithMiddleware;

if (typeof __DEVTOOLS__ !== 'undefined' && __DEVTOOLS__) {
  createStoreWithMiddleware = 
    applyMiddleware(
        wsClientMiddleware,
        loggerMiddleware
    )(createStore);
} else {
  createStoreWithMiddleware = applyMiddleware(
      wsClientMiddleware
  )(createStore);
}


/**
 * Creates a preconfigured store.
 */
export default function configureStore(initialState) {
  return createStoreWithMiddleware(rootReducer, initialState);
}
