# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token].remove 'Bearer '
      if verified_user = Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
