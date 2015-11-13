import React, {Component} from 'react';

export default class DeltaConnectConfig extends Component {
  render() {
    return (<div>
      <div className="two fields">
        <div className="field">
          <label>Bed radius</label>
          <div className="ui right labeled input">
            <input type="number" />
            <div className="ui basic label">
              mm
            </div>
          </div>
        </div>
        <div className="field">
          <label>Print volume height</label>
          <div className="field">
            <div className="ui right labeled input">
              <input type="number" />
              <div className="ui basic label">
                mm
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="field">
        <label>Diagonal rod length</label>
        <div className="field">
          <div className="ui right labeled input">
            <input type="number" />
            <div className="ui basic label">
              mm
            </div>
          </div>
        </div>
      </div>
      <div className="three fields">
        <div className="field">
          <label>Endstop offset A</label>
          <div className="field">
            <div className="ui right labeled input">
              <input type="number" />
              <div className="ui basic label">
                mm
              </div>
            </div>
          </div>
        </div>
        <div className="field">
          <label>Endstop offset B</label>
          <div className="field">
            <div className="ui right labeled input">
              <input type="number" />
              <div className="ui basic label">
                mm
              </div>
            </div>
          </div>
        </div>
        <div className="field">
          <label>Endstop offset C</label>
          <div className="field">
            <div className="ui right labeled input">
              <input type="number" />
              <div className="ui basic label">
                mm
              </div>
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
