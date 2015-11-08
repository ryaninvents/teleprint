import React, {Component} from 'react';

import '../semantic/dist/components/segment.css';

export default class Segment extends Component {
  render() {
    return (<div className="ui segment">
      {this.props.children}
    </div>);
  }
}
