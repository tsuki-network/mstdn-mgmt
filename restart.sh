#!/bin/bash

/home/mastodon/toot 【メンテナンス告知】当インスタンスは、今から10秒後、約1分間 Mastodon サービスの再起動を行います。その間、アクセスが円滑でないことがありますので、ご了承お願いいたします。

echo
echo wait 10 seconds ...
sleep 10s

echo restart mastodon-*.service
sudo systemctl stop mastodon-streaming.service mastodon-sidekiq.service mastodon-web.service
sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
sudo systemctl status --full --no-pager mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

echo wait for mastodon-web.service bootup ...
/home/mastodon/wait-for-boot.sh

/home/mastodon/toot 【メンテナンス終了】Mastodon サービスの再起動が完了しました。

