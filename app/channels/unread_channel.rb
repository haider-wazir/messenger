class UnreadChannel < ApplicationCable::Channel
  def subscribed
    stream_from "unread_#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
