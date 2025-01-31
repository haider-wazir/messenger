require 'redis'

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  timeout: 1,
  reconnect_attempts: 2,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)
