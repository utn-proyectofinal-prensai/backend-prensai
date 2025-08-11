# frozen_string_literal: true

module API
  module V1
class SessionsController < Devise::SessionsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session
      respond_to :json

      private

      def respond_with(current_user, _opts = {})
        render :create, formats: [:json], locals: { user: current_user }
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end