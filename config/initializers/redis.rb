require 'redis'
require 'openssl'

redis_url = ENV.fetch('REDIS_URL')

$redis = Redis.new(
  url: redis_url,
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
    ssl_version: :TLSv1_2
  }
)
