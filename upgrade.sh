#!/bin/bash

SERVICE_BRANCH=$(cat ~/.service-branch)
SERVICE_DOMAIN=$(cat ~/.service-domain)

export RAILS_ENV=production
pushd /home/mastodon/live > /dev/null
git fetch --all
git checkout $SERVICE_BRANCH > /dev/null 2>&1
git status | grep "up to date"
if [[ $? -eq 0 ]]; then exit 0; fi
git reset --hard origin/$SERVICE_BRANCH

MSTDN_UPGRADE_VERSION=$(git describe --tags --exact-match || echo "$(git describe --tags $(git rev-list --tags --max-co unt=1)) ($(git rev-parse HEAD))")
/home/mastodon/toot 【メンテナンス告知】当インスタンスは、今から約30分間 Mastodon $MSTDN_UPGRADE_VERSION へのアップデートを行います。その間、アクセスが円滑でないことがありますので、ご了承お願いいたします。

rbenv versions | grep $(cat .ruby-version)
if [[ $? -ne 0 ]]; then
  pushd /home/mastodon/.rbenv/plugins/ruby-build
  git pull
  popd
  rbenv install $(cat .ruby-version)
  rbenv global $(cat .ruby-version)
fi
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

while ! curl -sSLI https://$SERVICE_DOMAIN/.well-known/host-meta -o /dev/null -w '%{http_code}' | grep '200' | wc -l; do
  sleep 1s
done

/home/mastodon/toot 【メンテナンス終了】Mastodon $MSTDN_UPGRADE_VERSION へのアップデートが完了しました。
