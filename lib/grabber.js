var tmp = require('tmp')
var utils = require('./utils')
var http = require('http')
var https = require('https')
var config = require('./config').Config
const childProcess = require('child_process');
const fs = require('fs');

/**
 * Initialize the Grabber
 *
 * @param object s3 The S3 client
 */
function Grabber () {
  this.logger = require(config.get('logger'))
}

/**
 * Download an image from S3 or over http(s)
 *
 * @param string remoteImagePath The image url / s3 path
 * @param function} callback The callback function
 */
Grabber.prototype.download = function (bucket, region, remoteImagePath, callback) {
  var _this = this
  var extension = remoteImagePath.split('.').pop()
  var fileName = 
  tmp.file({dir: config.get('tmpDir'), postfix: '.' + extension}, function (err, localImagePath, fd) {
    if (err) return callback(err)

    fs.close(fd, function () {
      _this.logger.info('downloading', remoteImagePath, 'from s3 to local file', localImagePath)
      //config.descriptions = fs.readFileSync(process.env.PWD + "/data/example.json").toString()
      var stream = fs.createWriteStream(localImagePath)
      if (process.env.DEBUG) {
        console.log('In DOWNLOAD Method')
        console.log('Bucket:',bucket)
        console.log('Region:',region);
        console.log('Remote Image Path:',remoteImagePath);
        console.log('Local Image Path:', localImagePath);
      }

      //console.log('DESCIRPTIONS:', config.descriptions)
      if (remoteImagePath.match(/https?:\/\//)) { // we are thumbnailing a remote image.
        _this.getFileHTTP(remoteImagePath, localImagePath, stream, callback)
      } else { // we are thumbnailing an Object in our thumbnail S3 bucket.
        console.log('Until issue with transmogrifying upload path is not including s3.amazon.com in results, this is broke.  Exiting.')
        process.exit(0);
        _this.getFileS3(bucket, region, remoteImagePath, localImagePath, stream, callback)
      }
    }) // close immediately, we do not use this file handle.
  })
}

/**
 * Retrieve a file from a http(s) URI
 *
 * @param string remoteImagePath The image URI
 * @param string localImagePath The local image path
 * @param WriteStream stream The stream object for the local file
 * @param function callback The callback function
 */
Grabber.prototype.getFileHTTP = function (remoteImagePath, localImagePath, stream, callback) {
  var protocol = remoteImagePath.match('https://') ? https : http
     const ffmpeg_args = ["-ss", "00:00:01", "-i", remoteImagePath, "-y","-t","1",localImagePath]
     const ffmpeg = childProcess.execFile('ffmpeg',ffmpeg_args, function (error){
        callback(error, localImagePath);
      });
}

/**
 * Retrieve a file from S3
 *
 * @param string remoteImagePath The S3 path
 * @param string localImagePath The local image path
 * @param WriteStream stream The stream object for the local file
 * @param function callback The callback function
 */
Grabber.prototype.getFileS3 = function (bucket, region, remoteImagePath, localImagePath, stream, callback) {
  var _this = this
  var req = utils.s3(bucket, region).getFile(remoteImagePath, function (err, res) {
    // no response should count as an error.
    res = res || { statusCode: 503 }

    if (err || res.statusCode >= 400) {
      stream.end()
      return callback(Error('error retrieving from S3 status ' + res.statusCode))
    }

    stream.on('finish', function () {
      stream.close(function () { callback(null, localImagePath, _this.getMeta(res)) })
    })

    res.pipe(stream)

    res.on('error', function (err) {
      stream.end()
      callback(err)
    })

    res.on('end', function () {
      stream.end()
    })

  }).on('socket', function (socket) {  // abort connection if we're in idle state too long.
    socket.setTimeout(config.get('requestTimeout'))
    socket.on('timeout', function () {
      stream.end()
      req.abort()
      callback('socket timeout while downloading ' + remoteImagePath)
    })
  }).on('error', function (err) {
    stream.end()
    callback(err)
  })
}

// copy any x-amz-meta prefixed and x-amz-server-side-encryption headers
// to the thumbnail image being created.
Grabber.prototype.getMeta = function (res) {
  console.log('KEEP META Value:', config.get('keepMeta'))
  console.log('Keeps encryption value:',config.get('keepEncryption'))
  console.log('Headers:', res.headers)
  var metadata = {}
  if (config.get('keepMeta') || config.get('keepEncryption')) {
    for (var prop in res.headers) {
      if (prop === 'x-amz-server-side-encryption' || prop.slice(0, 11) === config.get('metaPrefix')) {
        metadata[prop] = res.headers[prop]
      }
    }
  }

  return metadata
}

exports.Grabber = Grabber
