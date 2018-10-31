#!/usr/bin/env /usr/local/bin/node
console.log(" -- Starting queue processing")
var path = require('path');
var thumbnaild = path.resolve(process.env.PWD,'bin','thumbnaild.js');
require(thumbnaild) (process.env)
//exec "$@"