require 'redis'

Redis.current = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
)
