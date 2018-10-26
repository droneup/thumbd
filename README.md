This image is a small collection of tools for creating batching the creation of thumbnails 
of videos in a S3 bucket.
# Getting started

* Build image
```docker build . -t du-thumbd```
* Log into bash
```docker run -it du-thumbd:latest bash```

Once logged in, you can test tools.

- Capture first second of video from S3 bucket

```ffmpeg -noaccurate_seek -ss 00:00:01 -i https://s3.amazonaws.com/thumbd-poc-videos/videos/star_trails.avi -frames:v 1 frame-1s.jpg```

The above will minimize bandwidth impact, and only retrieve whats necessary to create 1 second frame for jpg.

Once you have this clip, you can run through thumbd for various thumbnails of varying sizes. 

