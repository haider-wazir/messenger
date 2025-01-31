if defined?(ViteRuby)
  Rails.application.config.middleware.insert_before 0, Rack::Static, {
    urls: ["/vite-dev"],
    root: "public"
  }

  ViteRuby.configure do |config|
    config.build_cache_dir = 'tmp/vite-dev'
  end
end
