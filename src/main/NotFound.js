import React, {Component} from 'react';

import '../semantic/dist/components/icon.css';
import '../semantic/dist/components/header.css';

export default class NotFound extends Component {
  render() {
    return (<div style={{textAlign: 'center'}}>
      <h2 className="ui center aligned icon header">
        <i className="circular help icon"/>
        Not found
      </h2>
      <p>The page you're looking for isn't here.</p>
      <button className="large ui button">
        <i className="home icon" /> Go to main screen
      </button>
    </div>);
  }
}
