#!/usr/bin/env node
console.log(" -- Starting queue processing")
var thumbd = require('../lib')
var config = require('../lib/config').Config
var grabber = new thumbd.Grabber()
var saver = new thumbd.Saver();
(new thumbd.Worker({saver: saver,grabber: grabber})).start()
