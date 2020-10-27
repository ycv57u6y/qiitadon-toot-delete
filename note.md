
# 開発用ノート

## mastodon-api

### クライアント生成

```rb
require "mastodon"

client = Mastodon::REST::Client.new(
  base_url:     API_BASE_URL,
  bearer_token: ACCESS_TOKEN
)
```

ref: [Class: Mastodon::REST::Client](https://www.rubydoc.info/gems/mastodon-api/Mastodon/REST/Client), [Method: Mastodon::Client#initialize](https://www.rubydoc.info/gems/mastodon-api/Mastodon%2FClient:initialize)

### ステータスの取得

ref: [Method: Mastodon::REST::Statuses#statuses](https://www.rubydoc.info/gems/mastodon-api/Mastodon%2FREST%2FStatuses:statuses)

```rb
statuses = client.statuses(ACCOUNT_ID, {
  # options...
})
```

|オプション|説明|
|:--|:--|
|`limit`|最大取得数。設定値未満の数も返る|
|`max_id`|この ID より前のトゥートを取得対象にする|
|`min_id`|[**2.6.0**]（おそらく、これより後のトゥートを取得する）|

#### ステータス取得の仕様

Mastodon 2.3.3 を採用する現在の Qiitadon には `min_id` オプションがなく古いほうからトゥートを取得できない。

古いほうから任意の範囲のトゥートを取得するには、

1. ステータス取得
2. 最も古いトゥートの ID を `max_id` にして再取得

の繰り返しで、先頭の指定位置から古いトゥートをリクエストで返ってくるぶんだけ取得できるので、あとは工夫して何とかする。

## 経過日数をチェックして削除する場合

もし、簡易な方法で最古のトゥートから順に取得できるようになった場合は「◯◯日より古いトゥートを削除する」スクリプトも実装できる。

現在日時は `DateTime.now` で取得できる。

```rb
require "date"

now = DateTime.now
```

トゥートの投稿日時は取得したトゥートの `created_at` をパースすると `now` と比較可能なオブジェクトとなる。日時を減算すると差を `Rational` で返すので整数変換する。これが経過日数となる。

```rb
statuses.each { |status|
  created_at = DateTime.parse(status.created_at)
  days_ago   = (now - created_at).to_i

  if days_ago > 保護する日数 then
    # 削除処理
...
```
