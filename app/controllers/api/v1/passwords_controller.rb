# frozen_string_literal: true

module API
  module V1
    class PasswordsController < Devise::PasswordsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session

      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      private

      def redirect_options
        { allow_other_host: true }
      end

      def respond_with(resource, _opts = {})
        if resource.errors.empty?
          head :no_content
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def render_parameter_missing(_exception)
        render json: { errors: [{ message: I18n.t('api.errors.missing_param') }] }, status: :unprocessable_entity
      end
    end
  end
end
