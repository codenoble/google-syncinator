Google Syncinator [![Build Status](https://travis-ci.org/biola/google-syncinator.svg?branch=master)](https://travis-ci.org/biola/google-syncinator)
=================

Google Syncinator creates and syncs accounts from [trogdir-api](https://github.com/biola/trogdir-api) into a Google Apps domain.

Requirements
------------
- Ruby
- Redis server (for Sidekiq)
- MongoDB server
- trogdir-api installation
- Admin access to a Google Apps account
- Biola WS email table (just temporarily for legacy support)

Installation
------------
```bash
git clone git@github.com:biola/google-syncinator.git
cd google-syncinator
bundle install
cp config/settings.local.yml.example config/settings.local.yml
cp config/blazing.rb.example config/blazing.rb
```

Configuration
-------------
- Edit `config/settings.local.yml` accordingly.
- Edit `config/blazing.rb` accordingly.

Running
-------

```ruby
sidekiq -r ./config/environment.rb
```

Testing
-------

*Before running the specs you'll need to create a `ws_test` MySQL database.*

```ruby
bundle exec rspec
```

Deployment
----------
```bash
blazing setup [target name in blazing.rb]
git push [target name in blazing.rb]
```
