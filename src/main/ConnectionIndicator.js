import React, {Component} from 'react';
import {connect} from 'react-redux';

import Item from '../components/Item';

import '../semantic/dist/components/icon.css';

class ConnectionIndicator extends Component {
  render() {
    switch (this.props.serverConnection) {
      case 'offline':
        return (<Item>
          <i className="warning sign icon"/>
          No server connection
        </Item>)
      case 'connecting':
        return (<Item>
          <i className="asterisk loading icon"/>
          Connecting to server...
        </Item>)
      case 'online':
        return (<Item>
          <i className="disk outline icon"/>
          Server online
        </Item>)
        break;
    }
  }
}

function mapStateToProps({serverConnection}) {
  return {serverConnection};
}

export default connect(mapStateToProps)(ConnectionIndicator);
