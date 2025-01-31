require 'redis'
require 'openssl'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

ssl_params = if uri.scheme == 'rediss'
  {
    verify_mode: OpenSSL::SSL::VERIFY_PEER,
    ca_file: '/etc/ssl/certs/ca-certificates.crt',
    cert_store: OpenSSL::X509::Store.new
  }
else
  {}
end

$redis = Redis.new(
  url: redis_url,
  ssl_params: ssl_params
)
