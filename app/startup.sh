#!/bin/bash

# Remove temporary cache files
# rm -rf tmp/cache

# Remove any pre-exisitng PID files
# rm -rf /app/solr/pids/development/sunspot-solr-development.pid
rm -rf /app/tmp/pids/server.pid

bundle install --path=vendor/bundle
yarn install

# Configure bundle to use a local path for gems
bundle config path vendor/bundle

# Start the Solr service for Sunspot
bundle exec rails sunspot:solr:start

# Start the Rails server, binding it to all network interfaces
bundle exec rails s -p 8080 -b '0.0.0.0'
