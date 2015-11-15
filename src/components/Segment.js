import React, {Component} from 'react';

import '../semantic/dist/components/segment.css';

export default class Segment extends Component {
  render() {
    const className = this.props.className || '';
    return (<div className={`ui ${className} segment`}>
      {this.props.children}
    </div>);
  }
}
