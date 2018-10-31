#!/usr/bin/env node

var thumbd = require('../lib')
var _ = require('lodash')
var fs = require('fs')
var argv = process.argv
var mode = argv._.shift()
var config = require('../lib/config').Config
var serverOpts = {
  aws_key: 'awsKey',
  aws_secret: 'awsSecret',
  aws_region: 'awsRegion',
  bucket: 's3Bucket',
  convert_command: 'convertCommand',
  s3_acl: 's3Acl',
  s3_storage_class: 's3StorageClass',
  sqs_queue: 'sqsQueue',
  tmp_dir: 'tmpDir',
  log_level: 'logLevel',
  custom_logger: 'logger',
  profile: 'profile'
}
var thumbnailOpts = {
  aws_key: 'awsKey',
  aws_secret: 'awsSecret',
  aws_region: 'awsRegion',
  descriptions: 'descriptions',
  remote_image: 'remoteImage',
  sqs_queue: 'sqsQueue',
  bucket: 's3Bucket',
  log_level: 'logLevel',
  custom_logger: 'logger'
}
var ndm = require('ndm')('thumbd')
var opts = null
// make console output nicer for missing arguments.
process.on('uncaughtException', function (err) {
    var logger = require(config.get('logger'))
    logger.error(err.message)
})

/**
 * Extract the command line parameters
 *
 * @param object keys A mapping of cli option => config key names
 *
 * @return object
 */
function buildOpts (keys) {
    var opts = {}
    var pairs = _.pairs(keys)
    for (var i in pairs) {
      var argvKey = pairs[i][0]
      var envKey = argvKey.toUpperCase()
      var configKey = pairs[i][1]
      opts[configKey] = argv[argvKey] || config.get(configKey)
      if (opts[configKey] === null) {
        throw Error("The environment variable '" + envKey + "', or command line parameter '--" + argvKey + "' must be set.")
      }
    }
    return opts
  }

  opts = buildOpts(thumbnailOpts)
  var extraOpts = {}

  // allow region/bucket to vary on a job by job basis.
  if (argv.bucket) extraOpts.bucket = argv.bucket
  if (argv.aws_region) extraOpts.region = argv.aws_region
  if (argv.image_region) extraOpts.region = argv.image_region

  config.extend(opts)

  var client = new thumbd.Client()
  var logger = require(config.get('logger'))

  client.thumbnail(
    opts.remoteImage,
    JSON.parse(fs.readFileSync(opts.descriptions).toString()),
    extraOpts,
    function (err, res) {
      if (err) {
        logger.error(err)
      } else {
        logger.info(res)
      }
    }
  )