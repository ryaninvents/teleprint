import React, {Component} from 'react';

import MainMenu from './MainMenu';
import MachineControls from '../controls/MachineControls';
import GcodeConsole from '../controls/GcodeConsole';
import ConnectionPanel from '../controls/ConnectionPanel';

import '../semantic/dist/components/container.css' ;
import '../semantic/dist/components/site.css' ;
import '../semantic/dist/components/icon.css' ;
import '../semantic/dist/components/header.css' ;

import Grid, {Column} from '../components/Grid';

export default class Main extends Component {
  render() {
    return (<div className="" style={{padding: 20}}>
        <MainMenu/>
        <Grid>
          <Column width={5}>
            <ConnectionPanel />
          </Column>
          <Column width={5}>
            <MachineControls />
          </Column>
          <Column width={4}>
            <GcodeConsole />
          </Column>
        </Grid>
    </div>);
  }
}
