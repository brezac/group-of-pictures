### README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Versions 
```bash
- Ruby  (2.7.6p219)
- Rails (7.0.3) 
```

* System dependencies
```bash
- brew install ffmpeg
```

## How to Run

[1] Clone Repo
```bash
- git clone https://github.com/brezac/group-of-pictures.git
```

[2] Install the dependencies specified in the Gemfile
```bash
- bundle install --path=vendor/bundle
```

[3] Serve Program on http://0.0.0.0:8082
- bundle exec is a Bundler command to execute a script in the context of the current bundle (the one from your directory's Gemfile).
```bash
- bundle exec rails s -p 8082 -b 0.0.0.0
```

### Documentation of Endpoints

> ##### GET /videos/:videoId.mp4/group-of-pictures.json
> - Responds with json representation of all I-frames from any video asset present in app/assets/videos/

> ##### GET /videos/:videoName.mp4/group-of-pictures/:groupIndex.mp4
> - Responds with mp4 file containing ONLY the video data for the group of pictures requested (zero-indexed).

> ##### GET /videos/:videoName.mp4/group-of-pictures
> - Responds with a HTML document containing grid of all the groups of pictures in playable video elements and their timestamps.

