import React, {Component} from 'react';

import '../semantic/dist/components/label.css';

export default class Label extends Component {
  render() {
    const className = `ui label ${this.props.className}`;
    return (<div className={className}>
      {this.props.children}
    </div>);
  }
}
