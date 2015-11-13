import React, {Component} from 'react';
import {connect} from 'react-redux';

import Segment from '../components/Segment';
import Dropdown from '../components/Dropdown';

import {serialPortList} from '../networking/serialActions';

import '../semantic/dist/components/form.css';

class SerialConnectionPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      port: '/dev/ttyACM0',
      ports: ['/dev/ttyACM0', '/dev/ttyACM1']
    };
  }
  handleSerialPortRefresh() {
    this.props.serialPortList();
  }
  loadingStateIconClass(state) {
    switch (state) {
      case 'loading':
        return 'loading refresh icon';
      case 'idle':
        return 'refresh icon';
      case 'error':
      default:
        return 'warning sign icon';
    }
  }
  render() {
    const {loadingState} = this.props.serial;
    return (<Segment>
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
            <button
                className="fluid ui button"
                onClick={() => this.handleSerialPortRefresh()}
            >
              <i className={this.loadingStateIconClass(loadingState)} />
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
              <button
                  className="negative ui button"
                  onClick={() => this.props.onCancel()}>
                <i className="remove circle icon" />
                Cancel
              </button>
              <button
                  className="positive ui button"
                  onClick={() => this.props.onSubmit()}>
                <i className="plug icon" />
                Connect
              </button>
            </div>
          </div>
        </div>
      </Segment>);
  }
}

function mapStateToProps({serial}) {
  return {serial};
}

const mapDispatchToProps = {
  serialPortList,
};

export default connect(mapStateToProps, mapDispatchToProps)(SerialConnectionPanel);

