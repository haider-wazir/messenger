require 'redis'
require 'openssl'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

cert_store = OpenSSL::X509::Store.new
cert_store.set_default_paths

$redis = Redis.new(
  url: redis_url,
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_PEER,
    cert_store: cert_store
  }
)
