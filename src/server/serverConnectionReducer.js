import {
  WS_CONNECT,
  WS_CONNECT_SUCCESS,
  WS_DISCONNECT_SUCCESS
} from '../networking/wsClient';

export default function serverConnection(state = 'offline', action) {
  switch (action.type) {
    case WS_CONNECT: return 'connecting';
    case WS_CONNECT_SUCCESS: return 'online';
    case WS_DISCONNECT_SUCCESS: return 'offline';
    default: return state;
  }
}
