source "https://rubygems.org"

ruby "3.3.1"

# Core Rails
gem "rails", "~> 7.1.2"
gem "pg", "~> 1.4"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# API and Data
gem "jbuilder"
gem "rack-cors"

# Authentication and Security
gem "bcrypt", "~> 3.1.7"
gem "jwt"

# Real-time Features
gem "redis", ">= 4.0.1"

# Frontend Development
gem "vite_rails", "~> 3.0.19"
gem "vite_ruby", "~> 3.3"
gem "foreman"

# Cross-platform Compatibility
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end
