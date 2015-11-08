import React, {Component} from 'react';

import '../semantic/dist/components/feed.css';

export default class Feed extends Component {
  render() {
    return (<div className="ui feed">
      {this.props.children}
    </div>);
  }
}

export class Event extends Component {
  render() {
    let className = "event";
    return (<div className={className}>
      {this.props.children}
    </div>);
  }
}
