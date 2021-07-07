
require "logger"
require "mastodon"
require "dotenv"



# 以下の数の最新トゥートは削除しない
NUM_TO_KEEP = 100


# 設定値
API_BASE_URL  = "https://qiitadon.com"
LOG_LEVEL     = Logger::INFO
LOG_FILE_PATH = "./log"


# ログ
formatter = proc { |severity, datetime, progname, msg|
  if severity == "DEBUG" ||
     severity == "INFO"  ||
     severity == "WARN"  then
       STDOUT.puts msg
  else
       STDERR.puts msg
  end
  "[#{severity[0]}] #{datetime}: #{msg}\n"
}

logger = Logger.new(
  LOG_FILE_PATH,
  level: LOG_LEVEL,
  datetime_format: "%Y-%m-%d %H:%M:%S",
  formatter: formatter
)


# 開始
logger.info("Start toot delete...")
logger.info("Number of toots to keep: #{NUM_TO_KEEP}")


# 認証情報
Dotenv.load("./auth.env")
ACCOUNT_ID   = ENV["ACCOUNT_ID"]
ACCESS_TOKEN = ENV["ACCESS_TOKEN"]


# クライアント
client = Mastodon::REST::Client.new(
  base_url:     API_BASE_URL,
  bearer_token: ACCESS_TOKEN
)


# アカウントを取得
begin
  account = client.account(ACCOUNT_ID)
rescue
  logger.fatal("Could not get account: #{ACCOUNT_ID}")
  logger.close
  exit(1)
else
  logger.info("Getted account: #{ACCOUNT_ID}")
end


# 全体のトゥート数が保護する数以下なら終了
statuses_count = account.statuses_count
logger.info("Toots count: #{statuses_count}")

if statuses_count <= NUM_TO_KEEP then
  logger.info("Number of toots is less than or equal " +
              "to number to keeping(#{NUM_TO_KEEP})")
  logger.close
  exit(0)
end


# 保護するトゥートの末尾を含む範囲のトゥート群を取得するまでリクエストを繰り返す
sum_of_counts = 0
options = {limit: 40, max_id: nil}
begin
  loopc = 1
  while sum_of_counts <= NUM_TO_KEEP do
    logger.debug("Loop start... #{loopc}")

    statuses = client.statuses(ACCOUNT_ID, options)
    logger.debug("Getted statuses: #{statuses.size}")

    provisional_max_id = statuses.last.id
    options[:max_id] = provisional_max_id
    logger.debug("Provisional max ID: #{provisional_max_id}")

    sum_of_counts += statuses.size
    logger.debug("Sum of getted toots count: #{sum_of_counts}")

    loopc += 1
    sleep(1)
  end
rescue => e then
  logger.fatal("Raised fatal error while loop " +
               "for get a toot " +
               "to use for 'max_id': #{e}")
  logger.close
  exit(1)
end


# 保護するトゥートの末尾を抽出
index = statuses.size - (sum_of_counts - NUM_TO_KEEP) - 1
max_id = statuses.to_a[index].id
logger.info("Confirmed max ID: #{max_id}")


# 範囲内末尾のトゥートを目印にそれ以降の古いトゥートを削除する
sum_of_destroyed_statuses = 0
options = {limit: 30, max_id: max_id}
begin
  statuses = client.statuses(ACCOUNT_ID, options)
  statuses.each { |status|
    if client.destroy_status(status.id) then
      logger.info("Destroyed a toot: #{status.id}")
      sum_of_destroyed_statuses += 1
    else
      logger.error("Failed destroying a toot: #{status.id}")
    end

    sleep(1)
  }
rescue => e then
  logger.fatal("Raised fatal error while destroy toots: #{e}")
  logger.close
  exit(1)
end


# 終了
logger.info("Destroyed statuses: #{sum_of_destroyed_statuses}")
logger.info("...finish")
logger.close
exit(0)
