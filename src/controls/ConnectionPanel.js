import React, {Component} from 'react';

import Segment from '../components/Segment';
import Dropdown from '../components/Dropdown';

import '../semantic/dist/components/form.css';

export default class ConnectionPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      port: '/dev/ttyACM0',
      ports: ['/dev/ttyACM0', '/dev/ttyACM1']
    };
  }
  render() {
    return (<div className="ui segments">
      <Segment>
        <div className="ui form">
          <div className="inline fields">
            <div className="four wide field">
              <label>Type</label>
            </div>
            <div className="twelve wide field">
              <label>Serial port</label>
            </div>
          </div>
        </div>
      </Segment><Segment>
        <div className="ui form">
          <div className="inline fields">
            <div className="four wide field">
              <label>Port</label>
            </div>
            <div className="twelve wide field">
              <Dropdown options={this.state.ports} selected={this.state.port}
                onChange={(port) => this.setState({port})} />
            </div>
          </div>
          <div className="inline fields">
            <button className="fluid ui button">
              <i className="refresh icon" />
              Refresh ports list
            </button>
          </div>
          <div className="inline fields">
            <div className="four wide field">
              <label>Baudrate</label>
            </div>
            <div className="twelve wide field">
              <label>115200</label>
            </div>
          </div>
          <div className="inline fields">
            <div className="two ui buttons">
              <button className="negative ui button">
                <i className="remove circle icon" />
                Cancel
              </button>
              <button className="positive ui button">
                <i className="plug icon" />
                Connect
              </button>
            </div>
          </div>
        </div>
      </Segment>
    </div>);
  }
}
