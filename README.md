# du-thumbd

## Overview
Given a publically readable video file via http:// 
    1. Using ffmpeg, while preserving type, stream from 1 second marker, 1 second of video locally.
    2. Upload 4 thumbnails of that clip in same S3 folder as original video.
        * <basename>_640x1096.jpg (640X1096)
        * <basename>_medium.jpg (150x150)
        * <basename>_small.jpg (100x100)
        * <basename>__tiny.jpg (48x48)
    3. Preserving public_read acl @ Amazon

## Requires ENVKEY app, with the following:

* AWS_KEY
* AWS_REGION
* AWS_SECRET
* BUCKET
* CONVERT_COMMAND
* LOG_LEVEL
* PORT
* PROCESSED_DIR
* REQUEST_TIMEOUT
* S3_ACL
* S3_STORAGE_CLASS
* SQS_QUEUE
* STAGING_DIR
* TMP_DIR

## Processing videos
- Steps below require: ENVKEY defined in your shell; ie `exports ENVKEY=`
- To test: `echo $ENVKEY`

Build container: `docker build . -t du-thumbd`

Begin processing `docker run -it -e ENVKEY=$ENVKEY du-thumbd .droneup/process_queue.sh`

## Submitting video with cli

Build container: `docker build . -t du-thumbd`

Submit to SQS Queue: `docker run  -it -e ENVKEY=$ENVKEY -e REMOTE_IMAGE="http://url_to_video/vid.mov" du-thumbd .droneup/add_thumbnail.sh`

Or all in one: `docker run  -it -e ENVKEY=$ENVKEY -e REMOTE_IMAGE="http://url_to_video/vid.mov" $(docker build -t du-thumbd .).droneup/add_thumbnail.sh`

## Process full bucket

Build Container `docker build . -t du-thumbd`

Execute: `docker run -it -e ENVKEY=$ENVKEY du-thumbd .droneup/process_all.sh`

### Overview of processing

  1. For given bucket, list all objects `aws s3 ls --recursive`
  2. Loop through all results, for each do the following
  3. If string has a `.`, assume its a file to convert.
  4. Create an authenticated http url to s3 object, for purposes of streaming
  4. Use ffmpeg and stream 1 second of video, capture thumbnail as .jpg to local container
  5. Upload generated .jpg, and copy to same folder at s3, and with same name but with .jpg appended.