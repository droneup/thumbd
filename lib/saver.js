var _ = require('lodash')
var utils = require('./utils')
var url = require('url')
var config = require('./config').Config
var path = require('path');
/**
 * Initialize the Saver
 *
 * @param object s3 The S3 client
 */
function Saver () {
  this.logger = require(config.get('logger'))
}

/**
 * Save the (local or remote file) to disk
 *
 * @param string source The local file path, or remote file uri
 * @param string destination The local file path
 * @param function callback The callback function. Optional
 */
Saver.prototype.save = function (bucket, region, source, destination, metadata, callback) {
  var _this = this

  if (typeof callback === 'undefined') {
    callback = function () {}
  }

  var headers = {
    'x-amz-acl': config.get('s3Acl'),
    'x-amz-storage-class': config.get('s3StorageClass')
  }

  _.extend(headers, metadata) // set additional meta-data headers
  destination = destination.toString().replace('s3.amazonaws.com/','');
  destination = destination.toString().replace(bucket + '/','');
  if (destination.match(/https?:\/\//)) {
    destination = this.destinationFromURL(destination)
  }
  var newLocalPath = path.resolve(process.env.PWD,source);

  utils.s3(bucket, region).putFile(source, destination, function (err, res) {
    // if the region or bucket is wrong, this is reflected in a 301.
    if (res && res.statusCode !== 200) {
      return callback(Error('upload failure status = ' + res.statusCode))
    }
    if (err) return callback(err)

    res.on('error', function (err) {
      callback(err)
    })

    res.on('end', function () {
      _this.logger.info('saved ' + source + ' to ' + destination)
      callback()
    })
    res.resume()
  })
}

/**
 * Get a file path from a URL
 *
 * @param string destination The destination url. e.g. http://example.com/foo/test.jpg
 *
 * @return string The file path. E.g. example.com/foo/test.jpg
 */
Saver.prototype.destinationFromURL = function (destination) {
  var parsedURL = url.parse(destination)
  return parsedURL.hostname + parsedURL.path
}

exports.Saver = Saver
