require 'redis'
require 'open-uri'
require 'tempfile'

ca_cert_url = 'https://raw.githubusercontent.com/heroku/heroku-buildpack-ruby/main/certs/heroku-redis.crt'
ca_cert_file = Tempfile.new('heroku-redis.crt')
ca_cert_file.write(URI.open(ca_cert_url).read)
ca_cert_file.close

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL'),
  ssl: true,
  ssl_params: {
    ca_file: ca_cert_file.path
  }
)
