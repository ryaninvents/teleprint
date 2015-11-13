import {
  SERIAL_PORT_LIST,
  SERIAL_PORT_LIST_SUCCESS,
  SERIAL_PORT_LIST_FAILURE,
} from './serialActions';

const defaultState = {
  loadingState: 'idle',
};

export default function serial(state = defaultState, action) {
  switch (action.type) {
    case SERIAL_PORT_LIST:
      return {
        ...state,
        loadingState: 'loading',
      };
    case SERIAL_PORT_LIST_SUCCESS:
      return {
        ...state,
        loadingState: 'idle',
        ports: action.ports,
      };
    case SERIAL_PORT_LIST_FAILURE:
      return {
        ...state,
        loadingState: 'error',
      };
    default: return state;
  }
}

