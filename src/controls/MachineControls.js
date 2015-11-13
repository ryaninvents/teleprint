import React, {Component} from 'react';

import Segment from '../components/Segment';
import Grid, {Column} from '../components/Grid';

import JogPad from './JogPad';

export default class MachineControls extends Component {
  render() {
    return (<Segment>
      <Grid>
        <Column width={16}>
          <JogPad />
        </Column>
      </Grid>
    </Segment>);
  }
}
