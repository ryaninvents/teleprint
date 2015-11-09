import { combineReducers } from 'redux';

import serverConnection from './server/serverConnectionReducer';

export default combineReducers({
  serverConnection
});
