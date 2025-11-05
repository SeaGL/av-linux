'use strict';

var fs = require('fs');
var path = require('path');
var os = require('os');
var OBSWebSocket = require('obs-websocket-js').OBSWebSocket;

// TODO maybe(???) handle? The socket breaking?
// Reconnects etc.
// Also TODO figure out how the fuck to correctly get the password (*after* it's generated)

var obs = new OBSWebSocket();
var websocketPassword = JSON.parse(fs.readFileSync(path.join(os.homedir(), '.var/app/com.obsproject.Studio/config/obs-studio/plugin_config/obs-websocket/config.json'))).server_password;

// TODO handle OBS not having started yet
console.log('Connecting to OBS...');
var connectionPromise = obs.connect('ws://localhost:4455', websocketPassword, {rpcVersion: 1});
connectionPromise.then((result) => {
	console.log(`Connected to OBS server ${result.obsWebSocketVersion} (using RPC v${result.negotiatedRpcVersion})`)
});

async function getObsConnection() {
	await connectionPromise;
	return obs;
}

module.exports = getObsConnection;
