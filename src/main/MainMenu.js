import React, {Component} from 'react';

import Menu from '../components/Menu';
import Item from '../components/Item';

import '../semantic/dist/components/icon.css' ;

export default class MainMenu extends Component {
  render() {
    return (<Menu color="red"
                  pointing={true} 
                  fixed={true}
                  icons="labeled"
                  color="red"
                  side="top">
        <Item type="link" active={true}>
          <i className="dashboard icon" /> Controls
        </Item>
        <Item type="link" active={false}>
          <i className="cube icon" /> Model
        </Item>
        <Item type="link" active={false}>
          <i className="cut icon" /> Slicing
        </Item>
        <Item type="link" active={false}>
          <i className="configure icon" /> Settings
        </Item>
      </Menu>);
  }
}
