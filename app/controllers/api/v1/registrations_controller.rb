# frozen_string_literal: true

module API
  module V1
    class RegistrationsController < Devise::RegistrationsController
      include API::Concerns::ActAsAPIRequest
      protect_from_forgery with: :null_session

      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      private

      def sign_up_params
        params.expect(user: %i[email password password_confirmation username first_name last_name])
      end

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render :create, formats: [:json], locals: { user: resource }
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
