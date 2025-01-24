class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true
  has_many :unread_messages, dependent: :destroy
  
  validates :content, presence: true
  
  after_create :broadcast_message
  after_create :create_unread_messages
  after_destroy :broadcast_deletion
  
  private
  
  def broadcast_message
    if recipient_id
      # Private message - broadcast to both sender and recipient
      channel_name = "messages_#{[sender_id, recipient_id].sort.join('_')}"
      ActionCable.server.broadcast(channel_name, self.as_json(include: :sender))
    else
      # Group message - broadcast to group channel
      ActionCable.server.broadcast('messages_group', self.as_json(include: :sender))
    end
  end
  
  def broadcast_deletion
    if recipient_id
      # Private message - broadcast deletion to both sender and recipient
      channel_name = "messages_#{[sender_id, recipient_id].sort.join('_')}"
      ActionCable.server.broadcast(channel_name, { type: 'deletion', id: id })
    else
      # Group message - broadcast deletion to group channel
      ActionCable.server.broadcast('messages_group', { type: 'deletion', id: id })
    end
  end
  
  def create_unread_messages
    if recipient_id
      # Private message - create unread message for recipient
      UnreadMessage.create(message: self, user: recipient) unless sender_id == recipient_id
    else
      # Group message - create unread messages for all users except sender
      User.where.not(id: sender_id).find_each do |user|
        UnreadMessage.create(message: self, user: user)
      end
    end
  end
end
