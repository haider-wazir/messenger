require 'redis'
require 'openssl'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

$redis = Redis.new(
  url: redis_url,
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_PEER,
    ca_file: '/etc/ssl/certs/ca-certificates.crt'
  }
)
