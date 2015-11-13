
import React, {Component} from 'react';

export default class DeltaConnectConfig extends Component {
  render() {
    return (<div>
      <div className="three ui fields">
        <div className="field">
          <label>Print volume X size</label>
          <div className="ui right labeled input">
            <input type="number" />
            <div className="ui basic label">
              mm
            </div>
          </div>
        </div>
        <div className="field">
          <label>Print volume Y size</label>
          <div className="ui right labeled input">
            <input type="number" />
            <div className="ui basic label">
              mm
            </div>
          </div>
        </div>
        <div className="field">
          <label>Print volume Z size</label>
          <div className="ui right labeled input">
            <input type="number" />
            <div className="ui basic label">
              mm
            </div>
          </div>
        </div>
      </div>
      <div className="two ui buttons">
        <button
            className="negative ui button"
            onClick={() => this.props.onCancel()}>
          <i className="remove circle icon" />
          Cancel
        </button>
        <button
            className="positive ui button"
            onClick={() => this.props.onSubmit()}>
          <i className="plug icon" />
          Connect
        </button>
      </div>
    </div>);
  }
}
