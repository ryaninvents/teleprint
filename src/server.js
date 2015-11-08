import koa from 'koa';
import route from 'koa-route';
import websockify from 'koa-websocket';

import store, {appInit} from './server/store';

const app = websockify(koa());

process.nextTick(() => store.dispatch(appInit(app)));

const PORT = process.env.PORT || 9600;

app.listen(PORT);

console.log(`Server listening on port ${PORT}`);
