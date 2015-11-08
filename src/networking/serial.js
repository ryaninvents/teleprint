import serialPort, {SerialPort} from 'serialport';
import uuid from 'node-uuid';

export const SERIAL_PORT_CONNECT         = Symbol('teleprint/serialport/connect');
export const SERIAL_PORT_CONNECT_SUCCESS = Symbol('teleprint/serialport/connect/success');
export const SERIAL_PORT_CONNECT_FAILURE = Symbol('teleprint/serialport/connect/failure');

export const SERIAL_PORT_WRITE           = Symbol('teleprint/serialport/write');
export const SERIAL_PORT_WRITE_SUCCESS   = Symbol('teleprint/serialport/write/success');
export const SERIAL_PORT_WRITE_FAILURE   = Symbol('teleprint/serialport/write/failure');

export const SERIAL_PORT_DATA_RECEIVED   = Symbol('teleprint/serialport/data-received');

export const SERIAL_PORT_DRAIN           = Symbol('teleprint/serialport/drain');
export const SERIAL_PORT_DRAIN_SUCCESS   = Symbol('teleprint/serialport/drain/success');
export const SERIAL_PORT_DRAIN_FAILURE   = Symbol('teleprint/serialport/drain/failure');

export const SERIAL_PORT_LIST            = Symbol('teleprint/serialport/list');
export const SERIAL_PORT_LIST_SUCCESS    = Symbol('teleprint/serialport/list/success');
export const SERIAL_PORT_LIST_FAILURE    = Symbol('teleprint/serialport/list/failure');

export const SERIAL_PORT_DISCONNECT         = Symbol('teleprint/serialport/disconnect');
export const SERIAL_PORT_DISCONNECT_SUCCESS = Symbol('teleprint/serialport/disconnect/success');
export const SERIAL_PORT_DISCONNECT_FAILURE = Symbol('teleprint/serialport/disconnect/failure');
export const SERIAL_PORT_DISCONNECTED_VIA_DEVICE = Symbol('teleprint/serialport/disconnected-via-device');

export const SERIAL_PORT_ERROR = Symbol('teleprint/serialport/error');

const PORTS = {};

export const serialMiddleware = store => next => action => {
  // Pass along the action to other middleware no matter what
  next(action);

  switch (action.type) {
    case SERIAL_PORT_CONNECT:
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
    case SERIAL_PORT_WRITE:
      const {portID, writeRequestID} = action;
      const portInfo = PORTS[portID];
      if (!portInfo) {
        store.dispatch(serialPortWriteFailure(writeRequestID, new Error(`No port with ID ${portID}`));
        break;
      }
      const {port} = portInfo;
      if (!port.isOpen()) {
        store.dispatch(serialPortWriteFailure(writeRequestID, new Error(`Port ${portID} is not open for writing`));
        break;
      }
      port.write(action.data, (error) => {
        if (error) {
          return store.dispatch(serialPortWriteFailure(writeRequestID, error));
        }
        return store.dispatch(serialPortWriteSuccess(writeRequestID));
      });
      break;
    case SERIAL_PORT_DRAIN:
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
    case SERIAL_PORT_LIST:
      serialPort.list((err, ports) => {
        if (err) {
          store.dispatch(serialPortListFailure(err));
        }
        store.dispatch(serialPortListSuccess(ports));
      });
      break;
    default: break;
  }
};

export function serialPortConnect(port, options) {
  const portID = uuid.v1();
  return {
    type: SERIAL_PORT_CONNECT,
    port,
    portID,
    options
  };
}

export function serialPortConnectSuccess(portID) {
  return {
    type: SERIAL_PORT_CONNECT_SUCCESS,
    portID
  };
}

export function serialPortConnectFailure(portID, error) {
  return {
    type: SERIAL_PORT_CONNECT_FAILURE,
    portID,
    error
  };
}

export function serialPortWrite(portID, writeRequestID, data) {
  return {
    type: SERIAL_PORT_WRITE,
    portID,
    writeRequestID,
    data
  };
}

export function serialPortWriteSuccess(writeRequestID) {
  return {
    type: SERIAL_PORT_WRITE_SUCCESS,
    writeRequestID
  };
}

export function serialPortWriteFailure(writeRequestID, error) {
  return {
    type: SERIAL_PORT_WRITE_FAILURE,
    writeRequestID,
    error
  };
}

export function serialPortDataReceived(portID, data) {
  return {
    type: SERIAL_PORT_DATA_RECEIVED,
    portID,
    data
  };
}

export function serialPortDrain(portID, drainRequestID) {
  return {
    type: SERIAL_PORT_DRAIN,
    portID,
    drainRequestID
  };
}

export function serialPortDrainSuccess(drainRequestID) {
  return {
    type: SERIAL_PORT_DRAIN_SUCCESS,
    drainRequestID
  };
}

export function serialPortDrainFailure(drainRequestID, error) {
  return {
    type: SERIAL_PORT_DRAIN_FAILURE,
    drainRequestID,
    error
  };
}

export function serialPortList() {
  return {
    type: SERIAL_PORT_LIST
  };
}

export function serialPortListSuccess(ports) {
  return {
    type: SERIAL_PORT_LIST_SUCCESS,
    ports
  };
}

export function serialPortListFailure(error) {
  return {
    type: SERIAL_PORT_LIST_FAILURE
  };
}

export function serialPortDisconnect(portID, disconnectRequestID) {
  return {
    type: SERIAL_PORT_DISCONNECT,
    portID,
    disconnectRequestID
  };
}

export function serialPortDisconnectSuccess(disconnectRequestID) {
  return {
    type: SERIAL_PORT_DISCONNECT_SUCCESS,
    disconnectRequestID
  };
}

export function serialPortDisconnectFailure(disconnectRequestID, error) {
  return {
    type: SERIAL_PORT_DISCONNECT_FAILURE,
    disconnectRequestID,
    error
  };
}

export function serialPortDisconnectedViaDevice(portID) {
  return {
    type: SERIAL_PORT_DISCONNECTED_VIA_DEVICE,
    portID
  };
}

export function serialPortError(portID, error) {
  return {
    type: SERIAL_PORT_ERROR,
    error
  };
}
