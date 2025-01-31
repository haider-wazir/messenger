require 'redis'
require 'openssl'

redis_options = { url: ENV.fetch('REDIS_URL') }

if Rails.env.production?
  redis_options.merge!(
    ssl: true,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  )
end

$redis = Redis.new(redis_options)
