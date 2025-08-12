# frozen_string_literal: true

class JsonFailureApp < Devise::FailureApp
  def respond
    if json_request?
      self.status = 401
      self.content_type = 'application/json'
      message_key = warden_message || warden_options[:message] || :unauthenticated
      message = case message_key.to_sym
                when :invalid, :not_found_in_database
                  I18n.t('api.errors.invalid_credentials')
                else
                  I18n.t('api.errors.unauthorized')
                end
      self.response_body = { errors: [{ message: message }] }.to_json
    else
      super
    end
  end

  private

  def json_request?
    request.format.json? || request.xhr? || api_path?
  end

  def api_path?
    request.path.start_with?('/api/')
  end
end
