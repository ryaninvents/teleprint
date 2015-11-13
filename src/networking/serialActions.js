export const SERIAL_PORT_CONNECT         = ('teleprint/serialport/connect');
export const SERIAL_PORT_CONNECT_SUCCESS = ('teleprint/serialport/connect/success');
export const SERIAL_PORT_CONNECT_FAILURE = ('teleprint/serialport/connect/failure');

export const SERIAL_PORT_WRITE           = ('teleprint/serialport/write');
export const SERIAL_PORT_WRITE_SUCCESS   = ('teleprint/serialport/write/success');
export const SERIAL_PORT_WRITE_FAILURE   = ('teleprint/serialport/write/failure');

export const SERIAL_PORT_DATA_RECEIVED   = ('teleprint/serialport/data-received');

export const SERIAL_PORT_DRAIN           = ('teleprint/serialport/drain');
export const SERIAL_PORT_DRAIN_SUCCESS   = ('teleprint/serialport/drain/success');
export const SERIAL_PORT_DRAIN_FAILURE   = ('teleprint/serialport/drain/failure');

export const SERIAL_PORT_LIST            = ('teleprint/serialport/list');
export const SERIAL_PORT_LIST_SUCCESS    = ('teleprint/serialport/list/success');
export const SERIAL_PORT_LIST_FAILURE    = ('teleprint/serialport/list/failure');

export const SERIAL_PORT_DISCONNECT         = ('teleprint/serialport/disconnect');
export const SERIAL_PORT_DISCONNECT_SUCCESS = ('teleprint/serialport/disconnect/success');
export const SERIAL_PORT_DISCONNECT_FAILURE = ('teleprint/serialport/disconnect/failure');
export const SERIAL_PORT_DISCONNECTED_VIA_DEVICE = ('teleprint/serialport/disconnected-via-device');

export const SERIAL_PORT_ERROR = ('teleprint/serialport/error');

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

