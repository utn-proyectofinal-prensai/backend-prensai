# frozen_string_literal: true

class ExternalAiService
  include ActiveModel::Model

  attr_accessor :payload

  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    response = perform_request

    return handle_unsuccessful_response(response) unless response.success?

    build_success_payload(response.body)
  rescue Faraday::Error => error
    handle_connection_error(error)
  end

  private

  def http_client
    @http_client ||= Faraday.new do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def ai_module_base_url
    ENV.fetch('AI_MODULE_BASE_URL', 'http://localhost:3001')
  end

  def ai_service_url
    "#{ai_module_base_url.chomp('/')}/procesar-noticias"
  end

  def transform_response(ai_data)
    Rails.logger.info "AI service response: #{ai_data}"
    validate_response_structure(ai_data)

    {
      received: ai_data['recibidas'],
      processed: ai_data['procesadas'],
      news: ai_data['data'],
      errors: transform_errors(ai_data['errores'])
    }
  end

  def transform_errors(errors)
    return [] unless errors.is_a?(Array)

    errors.map do |error|
      {
        url: error['url'],
        reason: error['motivo']
      }
    end
  end

  def validate_response_structure(ai_data)
    required_fields = %w[recibidas procesadas data]
    missing_fields = required_fields.reject { |field| ai_data.key?(field) }

    return if missing_fields.empty?

    error_msg = "AI service response missing required fields: #{missing_fields.join(', ')}"
    Rails.logger.error error_msg
    raise StandardError, error_msg
  end

  def perform_request
    http_client.post(ai_service_url, payload)
  end

  def handle_unsuccessful_response(response)
    Rails.logger.error "AI service failed with status #{response.status}: #{response.body}"
    { ok: false, errors: response.body['errores'] }
  end

  def build_success_payload(body)
    transform_response(body).merge(ok: true)
  end

  def handle_connection_error(error)
    Rails.logger.error "AI service connection error: #{error.message}"
    nil
  end
end
