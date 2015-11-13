import React, {Component} from 'react';

import Segment from '../components/Segment';
import Dropdown from '../components/Dropdown';
import SerialConnectionPanel from './SerialConnectionPanel';
import SimulatorConnectionPanel from './SimulatorConnectionPanel';

import '../semantic/dist/components/form.css';

const PANELS = {
  "Serial port": SerialConnectionPanel,
  "Simulator": SimulatorConnectionPanel,
};

export default class ConnectionPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      type: Object.keys(PANELS)[0],
      types: Object.keys(PANELS),
    };
  }
  render() {
    const SelectedPanel = PANELS[this.state.type];
    return (<div className="ui segments">
      <Segment>
        <div className="ui form">
          <div className="inline fields">
            <div className="four wide field">
              <label>Type</label>
            </div>
            <div className="twelve wide field">
              <Dropdown options={this.state.types} selected={this.state.type}
                onChange={(type) => this.setState({type})} />
            </div>
          </div>
        </div>
      </Segment>
      <SelectedPanel
          onCancel={() => this.props.onCancel()}
          onSubmit={() => this.props.onSubmit()} />
    </div>);
  }
}
