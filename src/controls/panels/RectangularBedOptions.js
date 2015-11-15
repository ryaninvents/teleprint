import React, {Component} from 'react';

import '../../semantic/dist/components/form.css';

export default class RectangularBedOptions extends Component {
  render() {
    return (<div className="ui form">
      <div className="fields">
        <div className="four wide field">
          <label>Bed width</label>
          <div className="ui right labeled input">
            <input type="number" defaultValue={90}/>
            <div className="ui basic label">mm</div>
          </div>
        </div>
        <div className="four wide field">
          <label>Bed height</label>
          <div className="ui right labeled input">
            <input type="number" defaultValue={90}/>
            <div className="ui basic label">mm</div>
          </div>
        </div>
        <div className="four wide field">
          <label>Print origin X</label>
          <div className="ui right labeled input">
            <input type="number" defaultValue={0}/>
            <div className="ui basic label">mm</div>
          </div>
        </div>
        <div className="four wide field">
          <label>Print origin Y</label>
          <div className="ui right labeled input">
            <input type="number" defaultValue={0}/>
            <div className="ui basic label">mm</div>
          </div>
        </div>
      </div>
    </div>);
  }
}
