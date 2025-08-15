# frozen_string_literal: true

module API
  module V1
    class SessionsController < Devise::SessionsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session
      respond_to :json

      private

      def respond_with(_current_user, _opts = {})
        token = request.env['warden-jwt_auth.token']
        render json: {
          token: token,
          token_type: 'Bearer',
          expires_in: Warden::JWTAuth.config.expiration_time
        }
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end
