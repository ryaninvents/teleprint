import React, {Component} from 'react';

import '../semantic/dist/components/dropdown.css';

export default class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }
  options() {
    return this.props.options.map(opt => {
      if (typeof opt === 'string') {
        return {name: opt, value: opt};
      }
      if (!opt.value) {
        opt.name = opt.value;
      }
      return opt;
    });
  }
  selectedOption() {
    const {selected} = this.props;
    return this.options().filter(opt => opt.value === selected)[0];
  }
  render() {
    const {open} = this.state;
    const selected = (this.selectedOption() || {}).name;
    return (<div className={`ui dropdown active ${open ? 'visible' : 'hidden'}`} style={{minHeight: '1em'}}>
      <input type="hidden"/>
      <div className="text" onClick={() => this.setState({open:!open})}>
        {selected}
      </div>
      <i className="dropdown icon"/>
      <div className={`menu transition ${open ? 'visible' : 'hidden'}`} style={{
        display: open ? 'block' : 'none'
      }}>
        {
          this.options().map(opt => (<div className={`${opt.name === selected ? 'active selected' : ''} item`} onClick={() => {
            this.props.onChange(opt.value);
            this.setState({open: false});
          }}>
            { opt.name }
          </div>))
        }
      </div>
    </div>);
  }
}
