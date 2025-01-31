class User < ApplicationRecord
  has_secure_password
  
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
  has_many :unread_messages

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  after_create :broadcast_new_user

  private
  
  def password_required?
    new_record? || password.present?
  end

  def broadcast_new_user
    # Broadcast to global channel for new users
    ActionCable.server.broadcast('unread_global', { type: 'new_user', user: self.as_json(except: :password_digest) })
  end
end
