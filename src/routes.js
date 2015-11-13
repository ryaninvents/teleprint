import React from 'react';
import {Route, IndexRoute} from 'react-router';

import Main from './main/Main';
import NotConnected from './controls/NotConnected';
import MachineControls from './controls/MachineControls';
import GcodeConsole from './controls/GcodeConsole';
import ConnectionScreen from './main/ConnectionScreen';
import NotFound from './main/NotFound';

export default (
  <Route path="/" component={Main}>
    <IndexRoute component={NotConnected} />
    <Route path="connect" component={ConnectionScreen} />
    <Route path="gcode" component={GcodeConsole} />
    <Route path="controls" component={MachineControls} />
    <Route path="*" component={NotFound} />
  </Route>
);
