require 'redis'
require 'uri'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

$redis = Redis.new(
  url: redis_url,
  ssl: uri.scheme == 'rediss',
  ssl_params: { 
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
    verify_hostname: false
  }
)
