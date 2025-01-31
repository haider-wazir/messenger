module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      Rails.logger.info "ActionCable attempting connection with params: #{request.params.inspect}"
      self.current_user = find_verified_user
      Rails.logger.info "ActionCable connected as user: #{current_user.id}"
    end

    private

    def find_verified_user
      token = request.params[:token]
      
      if token
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
        user_id = decoded_token[0]['user_id']
        Rails.logger.info "ActionCable decoded user_id from token: #{user_id}"
        User.find_by(id: user_id)
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "ActionCable JWT decode error: #{e.message}"
      reject_unauthorized_connection
    end
  end
end
