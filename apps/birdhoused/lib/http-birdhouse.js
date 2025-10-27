'use strict';

var express = require('express');
var cors = require('cors');
var smartSpawn = require('smart-spawn');

var config = require('./config');

var router = express.Router();

router.use(express.json());
router.use(cors());

router.post('/exec-cmd', function(req, res) {
	// Validation
	if (!req.body) {
		res.status(400);
		return res.json({
			error: {
				hasError: true,
				message: 'no body was able to be parsed'
			}
		});
	}

	var cmdline = req.body.cmdline;

        if (!Array.isArray(cmdline) || cmdline.length === 0) {
                res.status(400);
		return res.json({
			error: {
				hasError: true,
				message: 'cmdline is not a populated array'
			}
		});
        }

	// Dev mode screening
	var allowlist = ['true', 'false', 'echo', 'rpm-ostree'];
	if (
		config.isProduction !== true
		&& (
			!allowlist.includes(cmdline[0])
			|| (cmdline[0] === 'rpm-ostree' && cmdline[1] !== 'upgrade')
		)
	) {
		console.error('We are in dev mode, skipping forbidden command execution: ' + cmdline.join(' '));
		return res.json({
			stdout: 'Synthesized stdout of forbidden command execution.'
		});
	}

	// Invoke
	console.log('Invoking command: ' + cmdline.join(' '));
	smartSpawn(cmdline.shift(), cmdline, process.cwd(), function(err, stdout) {
		if (err) {
			res.status(500);
			return res.json({
				stdout,
				// Is this all we actually want?
				// TODO: prolly not
				error: {
					hasError: true,
					message: err.message
				}
			});
		};

		res.json({ stdout });
	});
});

module.exports = router;
