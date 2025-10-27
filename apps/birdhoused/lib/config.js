'use strict';

var assert = require('assert');
var path = require('path');

// We namespace to `birdhouse` so we can just reuse SeaGL/av-linux' config file
// TODO figure out if we should like, loop waiting for config to become available in prod or something
assert(process.argv[2], 'config file must be passed as an argument');
var config = require(path.join('..', process.argv[2])).birdhouse;

module.exports = config;

console.log('Loaded config.');
