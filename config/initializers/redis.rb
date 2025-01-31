require 'redis'
require 'redis-client'

client = RedisClient.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  reconnect_attempts: 2,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

$redis = Redis.new(client: client)
