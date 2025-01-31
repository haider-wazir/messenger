require 'redis'
require 'openssl'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

$redis = if uri.scheme == 'rediss'
  Redis.new(
    url: redis_url,
    ssl: true,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  )
else
  Redis.new(url: redis_url)
end
