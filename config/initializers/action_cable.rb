require "action_cable/engine"

Rails.application.config.action_cable.url = ENV["ACTION_CABLE_URL"]
Rails.application.config.action_cable.allowed_request_origins = [ENV["APP_URL"]].compact

if ENV["REDIS_URL"].present?
  Rails.application.config.after_initialize do
    ActionCable.server.config.cable = { 
      adapter: :redis,
      url: ENV["REDIS_URL"]
    }
  end
end
