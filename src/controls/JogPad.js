import React, {Component} from 'react';
import {rgb, lighten} from 'color-ops';

const PADDING = 1;
const CENTER = [50, 50];

function paddedAnglePosition(angle, r, direction = 1, padding = PADDING) {
  padding *= direction;
  return [
    CENTER[0] + Math.cos(angle) * r - Math.sin(angle) * padding,
    CENTER[1] - Math.sin(angle) * r - Math.cos(angle) * padding
  ];
}

function flatten(_) {
  return _.reduce((a, b) => a.concat(b), []);
}

function quarterCirclePath(angle, r1, r2, travel = 90) {
  const fromAngle = angle * Math.PI / 180;
  const toAngle = (angle + travel) * Math.PI / 180;
  const s1 = paddedAnglePosition(fromAngle, r2),
        s2 = paddedAnglePosition(toAngle, r2, -1),
        s3 = paddedAnglePosition(toAngle, r1, -1),
        s4 = paddedAnglePosition(fromAngle, r1);
  return `M ${s1.join(' ')}
    A ${r2} ${r2} 0 0 0 ${s2.join(' ')}
    L ${s3.join(' ')}
    A ${r1} ${r1} 0 0 1 ${s4.join(' ')}
    Z`;
}

const red = rgb(219, 40, 40),
      orange = rgb(242, 113, 28),
      yellow = rgb(251, 189, 8),
      olive = rgb(181, 204, 24),
      green = rgb(33, 186, 69),
      teal = rgb(0, 181, 173),
      grey = rgb(118, 118, 118);

const RINGS = [
  [10, 20],
  [20, 30],
  [30, 40],
  [40, 50]
];

const ANGLES = [45, 135, 225, 315];

const COLORS = {
  45:  red,
  135: yellow,
  225: orange,
  315: olive
};

function colorForAngleAndRadius(a, r) {
  const baseColor = COLORS[a] || grey;
  const color = lighten(baseColor, -((50 - r) / 3)).map(n => Math.round(n));
  return `rgba(${color.join(',')})`;
}

class XYJogPad extends Component {
  render() {
    return (<g>
      {
        flatten(RINGS.map(([r1, r2]) => ANGLES.map(a => (
                  <path key={[r1,r2,a].join(',')}
                        d={quarterCirclePath(a, r1, r2+0.15)}
                        style={{cursor: 'pointer'}}
                        fill={colorForAngleAndRadius(a, r2)} />
                  ))))
      }
    </g>);
  }
}

export default class JogPad extends Component {
  render() {
    return (<svg viewBox="-1 -1 131 101">
      <XYJogPad />
      <rect x="110" y="0" width="20" height="100" fill="teal" />
    </svg>);
  }
}
