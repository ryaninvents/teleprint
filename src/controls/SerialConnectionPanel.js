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
    return (<div className="ui form">
          <div className="two fields">
            <div className="field">
              <label>Port</label>
              <Dropdown options={this.state.ports} selected={this.state.port}
                onChange={(port) => this.setState({port})} />
            </div>
            <div className="field">
              <label>Baudrate</label>
              <Dropdown
                  onChange={(baudrate) => this.setState({baudrate})}
                  options={['9600','115200']}
                  selected={this.state.baudrate}
              />
            </div>
          </div>
          <button
              className="fluid ui button"
              onClick={() => this.handleSerialPortRefresh()}
          >
            <i className={this.loadingStateIconClass(loadingState)} />
            Refresh ports list
          </button>
        </div>);
  }
}

function mapStateToProps({serial}) {
  return {serial};
}

const mapDispatchToProps = {
  serialPortList,
};

export default connect(mapStateToProps, mapDispatchToProps)(SerialConnectionPanel);

