# Parses Meetup Streaming API and saves data(event name) into Redis

## How to run the script
```
git clone git@github.com:barek2k2/meetup-streaming-api.git
cd meetup-streaming-api
bundle install
ruby main.rb
```

## Dependencies

 - Redis server(tested on 2.8.9 but should work on other version)
 - Ruby (>= 1.9.3)
 - Linux (tested on Ubuntu 14.04 LTS)
 
 
#### In case you dont have bundler installed, simply install it by
 `gem install bundler`