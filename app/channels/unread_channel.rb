class UnreadChannel < ApplicationCable::Channel
  def subscribed
    # Stream user-specific notifications
    stream_from "unread_#{current_user.id}"
    # Stream global notifications like new users
    stream_from "unread_global"
  end

  def unsubscribed
    stop_all_streams
  end
end
