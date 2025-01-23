class Api::V1::MessagesController < ApplicationController
  before_action :authorize_request
  
  def index
    @messages = if params[:user_id]
      Message.where(
        '(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)',
        current_user.id, params[:user_id],
        params[:user_id], current_user.id
      )
    else
      Message.where(recipient_id: nil)
    end
    
    render json: @messages.includes(:sender).order(created_at: :asc).as_json(include: :sender)
  end
  
  def create
    @message = Message.new(
      content: params[:content],
      sender: current_user,
      recipient_id: params[:recipient_id]
    )
    
    if @message.save
      render json: @message.as_json(include: :sender), status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @message = Message.find(params[:id])
    if @message.sender == current_user
      @message.destroy
      head :no_content
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
  def mark_read
    if params[:user_id]
      # Mark direct messages from specific user as read
      messages = Message.where(sender_id: params[:user_id], recipient: current_user)
    else
      # Mark group messages as read
      messages = Message.where(recipient_id: nil)
    end
    
    UnreadMessage.where(message: messages, user: current_user).destroy_all
    head :no_content
  end
  
  def unread_counts
    counts = {}
    
    # Get unread count for group messages
    group_count = UnreadMessage.joins(:message)
                             .where(user: current_user)
                             .where(messages: { recipient_id: nil })
                             .count
    counts['group'] = group_count if group_count > 0
    
    # Get unread counts for direct messages
    User.where.not(id: current_user.id).find_each do |user|
      count = UnreadMessage.joins(:message)
                          .where(user: current_user)
                          .where(messages: { sender_id: user.id, recipient: current_user })
                          .count
      counts[user.id.to_s] = count if count > 0
    end
    
    render json: counts
  end
end
