import { combineReducers } from 'redux';

import serverConnection from './server/serverConnectionReducer';
import serial from './networking/serialReducer';

export default combineReducers({
  serverConnection,
  serial,
});
