import React, {Component} from 'react';

import Segment from '../components/Segment';

import '../semantic/dist/components/form.css';
import '../semantic/dist/components/dropdown.css';

export default class ConnectionPanel extends Component {
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
              <div className="ui dropdown">
                <div className="text">/dev/ttyUSB0</div>
                <i className="dropdown icon"/>
              </div>
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
