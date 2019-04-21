#!/bin/bash

sudo systemctl stop mastodon-streaming.service mastodon-sidekiq.service mastodon-web.service
sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
sudo systemctl status mastodon-web.service mastodon-sidekiq.service --full --no-pager mastodon-streaming.service

