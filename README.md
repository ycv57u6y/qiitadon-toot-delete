
# qiitadon-toot-delete

n 個を残して古いトゥートを削除するスクリプト。

## 要件

- Ruby 2.5.x（または 2.3.x/2.4.x。mastodon-api に合わせる）
  - [mastodon-api](https://github.com/tootsuite/mastodon-api)
  - [dotenv](https://github.com/bkeepers/dotenv)

## 使用手順

### 認証情報

`auth.env` を作成し、次の変数をセット:

- **`ACCOUNT_ID`**: アカウントページ URL 末尾の **整数**
- **`ACCESS_TOKEN`**: Qiitadon 設定の「開発」より発行

```env
ACCOUNT_ID=...
ACCESS_TOKEN=...
```

### 設定

`main.rb` で保護するトゥート数を設定:

```rb
# この数だけ新しいトゥートは削除しない
NUM_TO_KEEP = 100
```

### 動作内容

スクリプトは指定の数以降のトゥートを削除するために、そのトゥートの ID を取得しようとする。そのとき、前作業として **指定の数に達するまでトゥートの取得を繰り返す。**

`100` を指定すると、新しい順に 100 個のトゥートが含まれるまでトゥートの取得を繰り返し、100 個目のトゥートを目印に、**その位置から、新しい順に** 古いトゥートが削除される。

一度の実行につき削除されるのは最大 30 個となる。既存のトゥートが多ければ、適度な間隔で定期的に実行し、何日もかけて目的の数まで削除させることになる。

### 実行

```sh
ruby main.rb
```

### ログ

デフォルトで `main.rb` と同じディレクトリの `log` ファイルに出力される。

```
[I] 2020-10-30 20:03:48 +0900: Start toot delete...
[I] 2020-10-30 20:03:48 +0900: Number of toots to keep: 100
[I] 2020-10-30 20:03:49 +0900: Getted account: 108013
[I] 2020-10-30 20:03:49 +0900: Toots count: 104
[I] 2020-10-30 20:03:54 +0900: Confirmed max ID: 105100058824321893
[I] 2020-10-30 20:03:54 +0900: Destroyed a toot: 105099550482434089
[I] 2020-10-30 20:03:55 +0900: Destroyed a toot: 105099397007093965
[I] 2020-10-30 20:03:56 +0900: Destroyed a toot: 105099164520129166
[I] 2020-10-30 20:03:58 +0900: Destroyed a toot: 105099151675052105
[I] 2020-10-30 20:03:59 +0900: Destroyed statuses: 4
[I] 2020-10-30 20:03:59 +0900: ...finish
```

## 定期実行（cron）

例として `run` スクリプトを作成:

```sh
#!/bin/bash

ruby /path/to/.../main.rb
```

実行権限を付与:

```sh
chmod +x run
```

cron に次の行を登録:

レート制限を考慮して 30 分ごとに実行。

```sh
# qiitadon-toot-delete
0-59/30 * * * * /path/to/.../run
```

### rbenvの場合

`.ruby-version` を反映させるにはこのプロジェクトのディレクトリに移動して `rbenv` 下の `ruby` を呼び出す。

`anyenv` で `rbenv` を導入している場合の例:

```sh
#!/bin/bash

cd /path/to/project
~/.anyenv/envs/rbenv/shims/ruby main.rb
```

`ruby` のパスを取得するには `which ruby` を実行すればよい。
