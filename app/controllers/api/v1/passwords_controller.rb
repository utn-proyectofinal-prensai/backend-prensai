# frozen_string_literal: true

module API
  module V1
    class PasswordsController < DeviseTokenAuth::PasswordsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session
      
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      private

      def redirect_options
        { allow_other_host: true }
      end

      def render_error(status, message, _data = nil)
        render json: { errors: Array.wrap(message:) }, status:
      end

      def render_parameter_missing(exception)
        render json: { errors: [{ message: I18n.t('api.errors.missing_param') }] }, status: :unprocessable_entity
      end
    end
  end
end
