# ffmpeg

## Extract JPGs from video (every 10th frame)
```
ffmpeg -i video.mp4 -vf fps=0.1 img-%04d.jpg
```

`%04d` - output image index with leading zeroes (4 digits wide)

## Extract JPGs from all videos in a directory (every frame)
```
for i in *.mp4; do PATTERN="output/`echo $i | sed s/"\.mp4"//g`-%04d.jpg"; echo $i; ffmpeg -i $i -vf fps=1 $PATTERN; done;
```

## Turn JPGs into video (1 frame/s)
```
ffmpeg -r 1 -i img-%04d.jpg -pix_fmt yuv420p video.mp4
```

`img-%04d.jpg` - look for images that start with *img-*, have 4 digits for the index and end with *.jpg*

## Extract audio from a video

* with no reencoding (check with `ffprobe` what the audio format is to get the extension right)

  ```
  ffmpeg -i input.mkv -vn -acodec copy output-audio.aac
  ```
  
* with reencoding to mp3

  ```
  ffmpeg -i input.mkv -q:a 0 -map a output-audio.mp3
  ```

* [source](https://stackoverflow.com/questions/9913032)
