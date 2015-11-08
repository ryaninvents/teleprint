import React, {Component} from 'react';

import Menu from '../components/Menu';
import Item from '../components/Item';

import '../semantic/dist/components/icon.css' ;

const MENU_TPL = [
{
  key: 'file',
  label: 'File',
  icon: 'folder open'
},
{
  key: 'view',
  label: 'View',
  icon: 'unhide'
},
{
  key: 'machines',
  label: 'Machines',
  icon: 'sitemap'
},
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
    return (<Menu size="small"
                  fixed={true}
                  borderless={true}
                  side="top">
        {
          MENU_TPL.map(item => <Item
              type="link"
              active={this.props.select && (activeItem === item.key)}
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
