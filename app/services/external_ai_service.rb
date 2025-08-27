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
    response = http_client.post(ai_service_url, payload)

    unless response.success?
      Rails.logger.error "AI service failed with status #{response.status}: #{response.body}"
      return
    end

    transform_response(response.body)
  rescue Faraday::Error => e
    Rails.logger.error "AI service connection error: #{e.message}"
    nil
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
      errors: ai_data['errores']
    }
  end

  def validate_response_structure(ai_data)
    required_fields = %w[recibidas procesadas data]
    missing_fields = required_fields.reject { |field| ai_data.key?(field) }

    return if missing_fields.empty?

    error_msg = "AI service response missing required fields: #{missing_fields.join(', ')}"
    Rails.logger.error error_msg
    raise StandardError, error_msg
  end
end
