
# qiitadon-toot-delete

最新 n 個を残して古いトゥートを削除するスクリプトです。

## 要件

次の環境の Docker イメージを使用します。

- Ruby 2.5.x
  - [mastodon-api](https://github.com/tootsuite/mastodon-api)
  - [dotenv](https://github.com/bkeepers/dotenv)

### Docker

このプロジェクトの `docker` ディレクトリに移動し、次のコマンドを実行します。

```sh
docker build -t mastodon-api .
```

## 使用手順

### 認証情報

`auth.env` を作成し、次の変数を記述します。

- **`ACCOUNT_ID`**: アカウントページ URL 末尾の **整数**
- **`ACCESS_TOKEN`**: Qiitadon 設定の「開発」より発行

```env
ACCOUNT_ID=...
ACCESS_TOKEN=...
```

### 設定

`main.rb` で保護するトゥート数を設定できます。

```rb
# 以下の数の最新トゥートは削除しない
NUM_TO_KEEP = 100
```

### 実行

`run` を実行します。Linux 版の Docker では `sudo` が必要です。

```sh
sudo ./run
```

## 動作内容

このスクリプトは設定で指定した数以降のトゥートを削除するために、その区切りとなるトゥートの ID を取得しようとします。そのため、**指定された数に達するまでトゥートの取得を繰り返します。**

例えば `100` に設定すると、新しいほうから 100 個目のトゥートが含まれるまでトゥートの取得を繰り返し、101 個目のトゥートから 102, 103...　の順にトゥートを削除していきます。**最古のトゥートから消えていくわけではありません。**

一度の実行につき削除されるのは最大 30 個です。既存のトゥートが多ければ、適度な間隔で定期的に実行し、何日もかけて目的の数まで削除する必要があります。

## ログ

`main.rb` と同じディレクトリに `log` ファイルが出力されます。

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

cron に `run` を登録してください。Qiitadon のレート制限を考慮して 30 分ごとにするなど間隔を置いて
ください。

```sh
# qiitadon-toot-delete
0-59/30 * * * * /path/to/.../run
```

### sudoを省略する

実行するユーザが `docker` グループに所属していれば `sudo` が不要になります。

```sh
sudo usermod <username> -aG docker
```
