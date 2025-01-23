class UnreadMessage < ApplicationRecord
  belongs_to :user
  belongs_to :message
  
  after_create :broadcast_unread_count
  after_destroy :broadcast_unread_count
  
  private
  
  def broadcast_unread_count
    # Get all unread counts for the user
    if message.recipient_id
      # For private messages
      counts = User.where.not(id: user.id).each_with_object({}) do |sender, acc|
        count = UnreadMessage.joins(:message)
                           .where(user: user)
                           .where(messages: { sender_id: sender.id, recipient_id: user.id })
                           .count
        acc[sender.id.to_s] = count if count > 0
      end
    else
      # For group messages
      group_count = UnreadMessage.joins(:message)
                               .where(user: user)
                               .where(messages: { recipient_id: nil })
                               .count
      counts = { 'group' => group_count } if group_count > 0
    end
    
    # Broadcast to user's channel
    ActionCable.server.broadcast("unread_#{user.id}", counts)
  end
end
