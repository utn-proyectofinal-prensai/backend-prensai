# frozen_string_literal: true

module API
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session

      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      private

      def sign_up_params
        params.expect(user: %i[email password password_confirmation username first_name last_name])
      end

      def render_create_success
        render :create, formats: [:json]
      end

      def render_error(status, message, _data = nil)
        render json: { errors: Array.wrap(message:) }, status:
      end

      def render_parameter_missing(_exception)
        render json: { errors: [{ message: I18n.t('api.errors.missing_param') }] }, status: :unprocessable_entity
      end
    end
  end
end
