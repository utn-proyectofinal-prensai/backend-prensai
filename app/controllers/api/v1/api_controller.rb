# frozen_string_literal: true

module API
  module V1
    class APIController < ActionController::API
      include API::Concerns::ActAsAPIRequest
      include Pundit::Authorization
      include Pagy::Backend

      before_action :authenticate_user!

      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      rescue_from ActiveRecord::RecordNotFound,        with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid,         with: :render_record_invalid
      rescue_from ActionController::ParameterMissing,  with: :render_parameter_missing
      rescue_from Pundit::NotAuthorizedError,          with: :render_forbidden
      rescue_from Warden::NotAuthenticated,            with: :render_unauthorized
      rescue_from Warden::JWTAuth::Errors::RevokedToken, with: :render_unauthorized
      rescue_from JWT::ExpiredSignature,               with: :render_unauthorized
      rescue_from JWT::DecodeError,                    with: :render_unauthorized
      rescue_from ActiveRecord::RecordNotDestroyed,    with: :render_record_not_destroyed
      rescue_from ActiveRecord::DeleteRestrictionError, with: :render_restriction_error

      private

      def render_not_found(exception)
        render_error(exception, { message: I18n.t('api.errors.not_found') }, :not_found)
      end

      def render_record_invalid(exception)
        render_error(exception, exception.record.errors.as_json, :unprocessable_entity)
      end

      def render_parameter_missing(exception)
        render_error(exception, { message: I18n.t('api.errors.missing_param') }, :bad_request)
      end

      def render_forbidden(exception)
        render_error(exception, { message: I18n.t('api.errors.forbidden') }, :forbidden)
      end

      def render_error(exception, errors, status)
        logger.info { exception }
        render json: { errors: Array.wrap(errors) }, status: status
      end

      def render_unauthorized(exception)
        render_error(exception, { message: I18n.t('api.errors.unauthorized') }, :unauthorized)
      end

      def render_record_not_destroyed(exception)
        render_error(exception, { message: I18n.t('api.errors.record_not_destroyed') }, :conflict)
      end

      def render_restriction_error(exception)
        render_error(exception, { message: I18n.t('api.errors.deletion_restricted') }, :conflict)
      end
    end
  end
end
