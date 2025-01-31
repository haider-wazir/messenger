require 'redis'
require 'uri'

redis_url = ENV.fetch('REDIS_URL')
uri = URI.parse(redis_url)

# Convert rediss:// to redis:// to bypass SSL
redis_url = redis_url.gsub('rediss://', 'redis://')

$redis = Redis.new(url: redis_url)
