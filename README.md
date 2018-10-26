This image is a small collection of tools for creating batching the creation of thumbnails 
of videos in a S3 bucket.
# Getting started

* Build image
```docker build . -t du-thumbd```
* Log into bash
```docker run -it -e ENVKEY="DETAILS OF APP" du-thumbd:latest .droneup/process_all.sh```

# Overview

  1. For given bucket, list all objects `aws s3 ls --recursive`
  2. Loop through all results, for each do the following
  3. If string has a `.`, assume its a file to convert.
  4. Create an authenticated http url to s3 object, for purposes of streaming
  4. Use ffmpeg and stream 1 second of video, capture thumbnail as .jpg to local container
  5. Upload generated .jpg, and copy to same folder at s3, and with same name but with .jpg appended.
  
TODO: If various sizes of thumbnails are necessary, then need to know those specifications. 

Some example options: 
```
{
        "suffix": "tiny",
        "width": 48,
        "height": 48
    },
    {
        "suffix": "small",
        "width": 100,
        "height": 100,
        "background": "red"
    },
    {
        "suffix": "medium",
        "width": 150,
        "height": 150,
        "strategy": "bounded"
}
```