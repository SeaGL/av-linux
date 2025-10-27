'use strict';

var Centrifuge = require('centrifuge').Centrifuge;

var config = require('./lib/config');

var hostTalkbackChanName = 'host_talkback';
var centrifuge = new Centrifuge(config.centrifugeUrl, config.centrifugeOpts);

// Connection logging boilerplate

centrifuge.on('connecting', function(ctx) {
	console.log(`Connecting to Centrifugo: ${ctx.code}, ${ctx.reason}`);
}).on('connected', function(ctx) {
	console.log(`Connected to Centrifugo over transport ${ctx.transport}`);
}).on('disconnected', function(ctx) {
	throw new Error(`Disconnected from Centrifugo, code ${ctx.code}, reason ${ctx.reason}`);
}).connect();

module.exports = centrifuge;
