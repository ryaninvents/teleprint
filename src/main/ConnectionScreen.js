import React, {Component} from 'react';

import ConnectionPanel from '../controls/ConnectionPanel';

export default class ConnectionScreen extends Component {
  render() {
    return (<div style={{maxWidth: 600, margin: 'auto'}}>
      <ConnectionPanel
          onCancel={() => this.props.history.goBack()}
          onSubmit={() => {} } />
    </div>);
  }
}
