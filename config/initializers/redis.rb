require 'redis'
require 'openssl'

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  ssl_params: {
    ca_file: ENV.fetch('SSL_CERT_FILE', '/etc/ssl/certs/ca-certificates.crt'),
    verify_mode: OpenSSL::SSL::VERIFY_PEER,
    verify_hostname: false
  }
)
