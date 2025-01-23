# Handles user-related operations (listing, profile management)
class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_request
  
  # GET /api/v1/users
  def index
    # Get all users except current user
    @users = User.where.not(id: current_user.id)
    render json: @users.as_json(except: :password_digest)
  end
end
