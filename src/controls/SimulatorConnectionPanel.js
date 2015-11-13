import React, {Component} from 'react';

import Segment from '../components/Segment';
import Dropdown from '../components/Dropdown';

import DeltaConnectConfig from './sim/DeltaConnectConfig';
import CartesianConnectConfig from './sim/CartesianConnectConfig';

import '../semantic/dist/components/form.css';
import '../semantic/dist/components/divider.css';

const PRINTER_TYPES = {
  'Cartesian': CartesianConnectConfig,
  'Delta': DeltaConnectConfig,
};

export default class SimulatorConnectionPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      type: Object.keys(PRINTER_TYPES)[0],
      types: Object.keys(PRINTER_TYPES),
    };
  }
  render() {
    const SimConfig = PRINTER_TYPES[this.state.type];
    return (<Segment>
      <div className="ui form">
        <div className="inline fields">
          <div className="four wide field">
            <label>Printer type</label>
          </div>
          <div className="twelve wide field">
            <Dropdown
                onChange={(type) => {this.setState({type})}}
                options={this.state.types}
                selected={this.state.type}
                />
          </div>
        </div>
        <SimConfig />
      </div>
    </Segment>);
  }
}
