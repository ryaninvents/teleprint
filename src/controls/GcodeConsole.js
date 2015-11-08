import React, {Component} from 'react';

import Segment from '../components/Segment';
import Grid, {Column} from '../components/Grid';
import Label from '../components/Label';
import Feed, {Event} from '../components/Feed';

import '../semantic/dist/components/input.css';
import '../semantic/dist/components/icon.css';
import '../semantic/dist/components/button.css';

export default class GcodeConsole extends Component {
  render() {
    return (<Segment>
      <Feed>
        <Event>
          <div className="label">
            <i className="angle double right icon"></i>
          </div>
          <code className="content">G0 X0 Y0</code>
        </Event>
        <Event>
          <div className="label">
            <i className="angle double left icon"></i>
          </div>
          <code className="content">ok</code>
        </Event>
      </Feed>
      <div className="fluid ui action input">
        <input type="text" placeholder="Enter a command"/>
        <button className="ui button">Send</button>
      </div>
    </Segment>);
  }
}
