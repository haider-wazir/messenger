class Api::V1::AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:register, :login]
  
  def register
    @user = User.new(user_params)
    
    if @user.save
      token = encode_token(user_id: @user.id)
      render json: { token: token }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    @user = User.find_by(email: params[:email])
    
    if @user&.authenticate(params[:password])
      token = encode_token(user_id: @user.id)
      render json: { token: token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  
  def logout
    head :no_content
  end
  
  def me
    render json: current_user
  end
  
  private
  
  def user_params
    params.permit(:username, :email, :password)
  end
end
