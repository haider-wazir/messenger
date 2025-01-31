require 'redis'

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  ssl_params: {
    ca_file: "/etc/ssl/certs/ca-certificates.crt"
  }
)
