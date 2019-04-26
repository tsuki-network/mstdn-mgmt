#!/bin/bash

/home/mastodon/toot 【メンテナンス告知】当インスタンスは、今から10秒後、約1分間 Mastodon サービスの再起動を行います。その間、アクセスが円滑でないことがありますので、ご了承お願いいたします。
sleep 10s

sudo systemctl stop mastodon-streaming.service mastodon-sidekiq.service mastodon-web.service
sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
sudo systemctl status --full --no-pager mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

while ! curl -sSLI https://tsuki.network/.well-known/host-meta -o /dev/null -w '%{http_code}' | grep '200' | wc -l; do
  sleep 1s
done

/home/mastodon/toot 【メンテナンス終了】Mastodon サービスの再起動が完了しました。

