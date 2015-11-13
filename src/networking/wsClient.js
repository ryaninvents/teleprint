import uuid from 'node-uuid';

export const WS_CONNECT              = ('teleprint/ws-client/connect');
export const WS_CONNECT_SUCCESS      = ('teleprint/ws-client/connect/success');
export const WS_CONNECT_FAILURE      = ('teleprint/ws-client/connect/failure');

export const WS_MESSAGE_SEND         = ('teleprint/ws-client/message-send');
export const WS_MESSAGE_SEND_SUCCESS = ('teleprint/ws-client/message-send/success');
export const WS_MESSAGE_SEND_FAILURE = ('teleprint/ws-client/message-send/failure');

export const WS_SERVER_MESSAGE       = ('teleprint/ws-client/server-message');

export const WS_DISCONNECT           = ('teleprint/ws-client/disconnect');
export const WS_DISCONNECT_SUCCESS   = ('teleprint/ws-client/disconnect/success');
export const WS_DISCONNECT_FAILURE   = ('teleprint/ws-client/disconnect/failure');

export const LOCAL_ACTION = Symbol('LOCAL_ACTION');

import {APP_INIT} from '../main/mainActions';

let socket = null;
let reconnectInterval = null;

const WS_PROTOCOL = document.location.protocol === 'https' ? 'wss:' : 'ws:';
const WS_URL = window.WS_URL || `${WS_PROTOCOL}//${document.location.hostname}:${window.WS_PORT || 9600}`;

const clientID = uuid.v1();

export const wsClientMiddleware = store => next => action => {
  next(action);
  switch (action.type) {
    case APP_INIT: {
      store.dispatch(wsConnect());
      break;
    }
    case WS_CONNECT: {
      const ws = new WebSocket(WS_URL);
      ws.onopen = () => {
        if (reconnectInterval) {
          clearInterval(reconnectInterval);
          reconnectInterval = null;
        }
        window.ws = socket = ws;
        store.dispatch(wsConnectSuccess());
      }
      ws.onmessage = (message) => {
        const recvdAction = JSON.parse(message.data);
        if (recvdAction.clientID !== clientID) {
          store.dispatch(recvdAction);
        }
      }
      ws.onerror = () => {
        if (ws.readyState === WebSocket.CLOSED) {
          store.dispatch(wsDisconnectSuccess());
          if (!reconnectInterval)
            reconnectInterval = setInterval(() => store.dispatch(wsConnect()), 5000);
        }
      }
      ws.onclose = () => {
        store.dispatch(wsDisconnectSuccess());
        if (!reconnectInterval)
          reconnectInterval = setInterval(() => store.dispatch(wsConnect()), 5000);
      }
    }
    default:
      if (action[LOCAL_ACTION]) {
        break;
      }
      if (socket && socket.readyState === WebSocket.OPEN) {
        action = {
          ...action,
          clientID,
        };
        socket.send(JSON.stringify(action));
      }
  }
};

export function wsConnect() {
  return {
    type: WS_CONNECT
  };
}

export function wsConnectSuccess() {
  return {
    type: WS_CONNECT_SUCCESS
  };
}

export function wsDisconnectSuccess() {
  return {
    type: WS_DISCONNECT_SUCCESS
  };
}
