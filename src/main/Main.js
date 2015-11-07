import React, {Component} from 'react';

import MainMenu from './MainMenu';

import '../semantic/dist/components/container.css' ;
import '../semantic/dist/components/site.css' ;
import '../semantic/dist/components/icon.css' ;
import '../semantic/dist/components/header.css' ;

export default class Main extends Component {
  render() {
    return (<div className="ui container">
        <MainMenu/>
    </div>);
  }
}
