import React, {Component} from 'react';

import '../../semantic/dist/components/form.css';

export default class CircularBedOptions extends Component {
  render() {
    return (<div className="ui form">
      <div className="fields">
        <div className="field">
          <label>Bed radius</label>
          <div className="ui right labeled input">
            <input type="number" defaultValue={90}/>
            <div className="ui basic label">mm</div>
          </div>
        </div>
      </div>
    </div>);
  }
}
