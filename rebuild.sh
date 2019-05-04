#!/bin/bash

export RAILS_ENV=production
pushd /home/mastodon/live > /dev/null
rbenv versions | grep $(cat .ruby-version)
if [[ $? -ne 0 ]]; then
  pushd /home/mastodon/.rbenv/plugins/ruby-build
  git pull
  popd
  rbenv install $(cat .ruby-version)
  rbenv global $(cat .ruby-version)
fi
. ~/.nvm/nvm.sh
nvm install $(cat .nvmrc)
nvm use $(cat .nvmrc)
npm install -g npm

gem install bundler
bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without development test
yarn install --pure-lockfile
SKIP_POST_DEPLOYMENT_MIGRATIONS=true bundle exec rails db:migrate
sudo systemctl stop mastodon-streaming.service mastodon-sidekiq.service mastodon-web.service
bundle exec rails assets:precompile
sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
bundle exec rails db:migrate
popd > /dev/null

sudo systemctl status --full --no-pager mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

/home/mastodon/wait-for-boot.sh

