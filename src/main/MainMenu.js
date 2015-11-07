import React, {Component} from 'react';

import Menu from '../components/Menu';
import Item from '../components/Item';

import '../semantic/dist/components/icon.css' ;

const MENU_TPL = [
{
  key: 'controls',
  label: 'Controls',
  icon: 'dashboard'
},
{
  key: 'model',
  label: 'Model',
  icon: 'cube'
},
{
  key: 'slicing',
  label: 'Slicing',
  icon: 'cut'
},
{
  key: 'settings',
  label: 'Settings',
  icon: 'configure'
}
];

export default class MainMenu extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeItem: 'controls'
    };
  }
  render() {
    const {activeItem} = this.state;
    return (<Menu color="red"
                  pointing={true}
                  fixed={true}
                  icons="labeled"
                  color="red"
                  side="top">
        {
          MENU_TPL.map(item => <Item
              type="link"
              active={activeItem === item.key}
              key={item.key}
              onClick={() => this.handleItemClick(item.key)}>
              <i className={`${item.icon} icon`} /> {item.label}
            </Item>)
        }
      </Menu>);
  }
  handleItemClick(activeItem) {
    this.setState({activeItem})
  }
}
