import React, {Component} from 'react';

import '../semantic/dist/components/menu.css';

const classNameDescriptors = {
  "ui menu": true,
  vertical(_) {
    return _.props.direction === 'vertical';
  },
  borderless(_) {
    return _.props.borderless === 'true';
  },
  pointing(_) {
    return _.props.pointing;
  },
  fixed(_) {
    return _.props.fixed;
  },
  icon(_) {
    return _.props.icons === "plain";
  },
  ["labeled icon"](_) {
    return _.props.icons === "labeled";
  },
  left(_) {
    return _.props.side === "left";
  },
  top(_) {
    return _.props.side === "top";
  },
  small(_) {
    return _.props.size === "small";
  }
};

export default class Menu extends Component {
  generateClassName() {
    return Object.keys(classNameDescriptors)
                 .filter(k => classNameDescriptors[k] === true || classNameDescriptors[k](this))
                 .concat(this.props.color ? [this.props.color] : [])
                 .join(' ');
  }
  render() {
    return (<div className={this.generateClassName()}>
        {this.props.children}
    </div>);
  }
}
