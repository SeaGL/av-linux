'use strict';

var express = require('express');

var obs = require('./obs');

var router = express.Router();

router.get('/set-livestream-state', async function(req, res) {
	var state = JSON.parse(req.query.state.toLowerCase());
	console.log('Received request to set livestream state: ' + state);

	// TODO update these with the actual names
	var targetScene = state ? 'splash' : 'Ad Roll';

	var client = await obs();
	await client.call('SetCurrentProgramScene', {sceneName: targetScene});

	// TODO lol should we like... actually send something back
	res.send();
});

module.exports = router;
