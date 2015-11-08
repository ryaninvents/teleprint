import 'babel/polyfill';
import React from 'react';
import ReactDOM from 'react-dom';
import {Provider} from 'react-redux';
import {Router} from 'react-router';

import createBrowserHistory from 'history/lib/createBrowserHistory';
import {useBasename} from 'history';

import configureStore from './store/configureStore';
import routes from './routes';
import {APP_INIT} from './main/mainActions';

import Main from './main/Main';

const store = configureStore();
const history = useBasename(createBrowserHistory)({
  basename: '/'
});

ReactDOM.render(
  <Provider store={store}>
    <Router history={history} children={routes} />
  </Provider>,
  document.getElementById('root'),
  function () {
    store.dispatch({type: APP_INIT});
  }
);
