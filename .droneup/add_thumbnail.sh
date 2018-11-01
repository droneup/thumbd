#!/usr/bin/env node
console.log(" -- Adding", process.env.REMOTE_IMAGE,'to SQS')
var thumbd = require('../lib')
var config = require('../lib/config').Config
var fs = require('fs')
var client = new thumbd.Client()
var logger = require(config.get('logger'))
console.log(process.env.DESCRIPTIONS);

var opts = {
  aws_key: process.env.AWS_KEY,
  aws_secret: process.env.AWS_SECRET,
  aws_region: process.env.AWS_REGION,
  descriptions: process.env.DESCRIPTIONS || process.env.PWD + "/data/example.json",
  remote_image: process.env.REMOTE_IMAGE,
  sqs_queue: process.env.SQS_QUEUE,
  bucket: process.env.BUCKET,
  log_level: process.env.LOG_LEVEL,
  custom_logger: 'logger'
}
//TODO: Put back sizing descriptions for various thumbnails.

opts.descriptions = fs.readFileSync(opts.descriptions).toString() //Ignore this, does nothing.
client.thumbnail(opts.remote_image,opts.descriptions, opts, function (err, res) {
    if (err) {
            logger.error(err)
        } else {
            logger.info(res)
        }
    }
)
//exec "$@"