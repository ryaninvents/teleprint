import React, {Component} from 'react';

import Segment from '../components/Segment';
import Grid, {Column} from '../components/Grid';
import Label from '../components/Label';

import JogPad from './JogPad';

export default class MachineControls extends Component {
  render() {
    return (<Segment>
      <Label className="green top left attached">
        Connected to delicate-dust-667
      </Label>
      <Grid>
        <Column width={16}>
          <JogPad />
        </Column>
      </Grid>
    </Segment>);
  }
}
