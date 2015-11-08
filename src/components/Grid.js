import React, {Component} from 'react';

import '../semantic/dist/components/grid.css';

export default class Grid extends Component {
  render() {
    return (<div className="ui grid">
      {this.props.children}
    </div>);
  }
}

const NUMBERS = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen'
];

export class Column extends Component {
  render() {
    let className = "ui column";
    if (this.props.width) {
      className += ` ${NUMBERS[this.props.width] || ''} wide`;
    }
    return (<div className={className}>
      {this.props.children}
    </div>);
  }
}
