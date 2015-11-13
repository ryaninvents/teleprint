import React, {Component} from 'react';

import '../semantic/dist/components/icon.css';
import '../semantic/dist/components/header.css';

export default class NotConnected extends Component {
  render() {
    return (<div style={{textAlign: 'center'}}>
      <h2 className="ui center aligned icon header">
        <i className="circular moon icon"/>
        Not connected
      </h2>
      <p>Connect to a 3D printer to get started.</p>
      <a onClick={() => this.go("/connect")} className="large ui icon labeled positive button">
        <i className="lightning icon" /> Connect
      </a>
    </div>);
  }
  go(href) {
    this.props.history.pushState(null, this.props.history.createHref(href));
  }
}
