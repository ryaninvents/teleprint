import serialPort, {SerialPort} from 'serialport';
import uuid from 'node-uuid';

import {
  SERIAL_PORT_CONNECT,
  SERIAL_PORT_WRITE,
  SERIAL_PORT_DRAIN,
  SERIAL_PORT_LIST,
  serialPortConnectFailure,
  serialPortConnectSuccess,
  serialPortDataReceived,
  serialPortDisconnectedViaDevice,
  serialPortError,
  serialPortWriteSuccess,
  serialPortWriteFailure,
  serialPortDrainSuccess,
  serialPortDrainFailure,
  serialPortListFailure,
  serialPortListSuccess,
} from './serialActions';

const PORTS = {};

export const serialMiddleware = store => next => action => {
  // Pass along the action to other middleware no matter what
  next(action);

  switch (action.type) {
    case SERIAL_PORT_CONNECT: {
      const {portID} = action;
      const port = new SerialPort(action.port, action.options);
      port.on('open', (err) => {
        if (err) {
          store.dispatch(serialPortConnectFailure(portID, err));
          return;
        }
        PORTS[portID] = {
          port,
          action: {...action},
          portID
        };
        store.dispatch(serialPortConnectSuccess(portID));
        port.on('data', (data) => {
          store.dispatch(serialPortDataReceived(portID, data));
        });
        port.on('close', () => {
          store.dispatch(serialPortDisconnectedViaDevice(portID));
          delete PORTS[portID];
        });
        port.on('error', (error) => {
          store.dispatch(serialPortError(portID, error));
        });
      });
      break;
    }
    case SERIAL_PORT_WRITE: {
      const {portID, writeRequestID} = action;
      const portInfo = PORTS[portID];
      if (!portInfo) {
        store.dispatch(serialPortWriteFailure(writeRequestID, new Error(`No port with ID ${portID}`)));
        break;
      }
      const {port} = portInfo;
      if (!port.isOpen()) {
        store.dispatch(serialPortWriteFailure(writeRequestID, new Error(`Port ${portID} is not open for writing`)));
        break;
      }
      port.write(action.data, (error) => {
        if (error) {
          return store.dispatch(serialPortWriteFailure(writeRequestID, error));
        }
        return store.dispatch(serialPortWriteSuccess(writeRequestID));
      });
      break;
    }
    case SERIAL_PORT_DRAIN: {
      const {portID, drainRequestID} = action;
      const portInfo = PORTS[portID];
      if (!portInfo) {
        store.dispatch(serialPortDrainFailure(drainRequestID, new Error(`No port with ID ${portID}`)));
        break;
      }
      const {port} = portInfo;
      if (!port.isOpen()) {
        store.dispatch(serialPortDrainFailure(drainRequestID, new Error(`Port ${portID} is not open; cannot drain`)));
        break;
      }
      port.drain((error) => {
        if (error) {
          return store.dispatch(serialPortDrainFailure(drainRequestID, error));
        }
        return store.dispatch(serialPortDrainSuccess(drainRequestID));
      });
      break;
    }
    case SERIAL_PORT_LIST: {
      console.log('listing...');
      serialPort.list((err, ports) => {
        console.log('listed', err, ports);
        if (err) {
          return store.dispatch(serialPortListFailure(err));
        }
        return store.dispatch(serialPortListSuccess(ports || []));
      });
      break;
    }
    default: break;
  }
};

