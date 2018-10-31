#!/usr/bin/env /usr/local/bin/node
console.log(" -- Starting queue processing")
var path = require('path');
var serverd = path.resolve(process.env.PWD,'bin','serverd.js');
require(serverd) (process.env)
//exec "$@"