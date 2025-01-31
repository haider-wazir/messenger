require 'redis'

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_PEER,
    verify_hostname: false
  }
)
