# frozen_string_literal: true

class ExternalAiService
  include ActiveModel::Model

  ENDPOINTS = {
    process_news: 'procesar-noticias',
    generate_report: 'generate-informe'
  }.freeze

  attr_accessor :payload, :action

  validates :action, presence: true, inclusion: { in: ENDPOINTS.keys }

  def self.process_news(payload)
    new(payload:, action: :process_news).call
  end

  def self.generate_report(payload)
    new(payload:, action: :generate_report).call
  end

  def initialize(attributes = {})
    super
    self.action = action&.to_sym
  end

  def call
    return unless valid?

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
    path = ENDPOINTS.fetch(action)
    "#{ai_module_base_url.chomp('/')}/#{path}"
  end

  def transform_process_news_response(ai_data)
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
    errors = extract_errors(response.body)
    { ok: false, errors: errors }
  end

  def build_success_payload(body)
    transformed = transform_response(body)
    transformed = transformed.to_h if transformed.respond_to?(:to_h)
    raise StandardError, 'AI service response handler must return a hash' unless transformed.is_a?(Hash)

    transformed.merge(ok: true)
  end

  def transform_response(body)
    case action
    when :process_news
      transform_process_news_response(body)
    when :generate_report
      transform_generate_report_response(body)
    else
      body
    end
  end

  def transform_generate_report_response(ai_data)
    {
      content: ai_data['informe'],
      metadata: ai_data.fetch('metadatos', {}).to_h
    }
  end

  def handle_connection_error(error)
    Rails.logger.error "AI service connection error: #{error.message}"
    nil
  end

  def extract_errors(body)
    return body['errores'] || body['errors'] if body.is_a?(Hash)

    body
  end
end
