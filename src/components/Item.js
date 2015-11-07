import React, {Component} from 'react';

import '../semantic/dist/components/item.css';

export default class Item extends Component {
  render() {
    return (<div className={`${this.props.active ? 'active' : ''} ${this.props.type || ''} item`}
          onClick={this.props.onClick}>
      {this.props.children}
    </div>);
  }
}
