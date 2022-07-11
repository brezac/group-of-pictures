# README

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

* How to Run

* Clone Repo
```bash
- git clone https://github.com/brezac/group-of-pictures.git
```

* Install the dependencies specified in the Gemfile
```bash
- bundle install --path=vendor/bundle
```

* Serve Program on http://0.0.0.0:8082
- bundle exec is a Bundler command to execute a script in the context of the current bundle (the one from your directory's Gemfile).
```bash
- bundle exec rails s -p 8082 -b 0.0.0.0
```

