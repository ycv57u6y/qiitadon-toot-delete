
# qiitadon-toot-delete

n 個を残して古いトゥートを削除するスクリプト。

- トゥート取得の都合上、最古のトゥートから降順ではなく、保護範囲外の先頭から削除する
- デフォルトで一度の実行につき 30 個削除する
- 定期実行は cron など各々の方法で行う

## 要件

- Ruby 2.5.x（または 2.3.x/2.4.x。mastodon-api に合わせる）
  - [mastodon-api](https://github.com/tootsuite/mastodon-api)
  - [dotenv](https://github.com/bkeepers/dotenv)

## 認証情報

`auth.env` を作成し、次の変数を設定すること:

- **`ACCOUNT_ID`**: アカウントページ URL 末尾の **整数**
- **`ACCESS_TOKEN`**: Qiitadon 設定の「開発」より発行

```env
ACCOUNT_ID=...
ACCESS_TOKEN=...
```

## レート制限

トゥート削除のリクエストのレート制限は **1 アカウントあたり 30 回/30 分。**

- [Rate limits](https://docs.joinmastodon.org/api/rate-limits/) - [Mastodon Documentation](https://docs.joinmastodon.org/)

## cronでの定期実行

anyenv で ruby を導入しているものとする。次のスクリプトを作成し、実行権限を付与する。

```sh
#!/bin/bash

cd <このディレクトリへの絶対パス>
~/.anyenv/envs/rbenv/shims/ruby main.rb
```

cron に次の行を登録。レート制限を考慮して 30 分ごとに実行。

```sh
# qiitadon-toot-delete
0-59/30 * * * * <上記スクリプトへの絶対パス>
```
