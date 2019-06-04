#!/bin/bash

sudo systemctl status --full --no-pager mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

