# frozen_string_literal: true

class NewsProcessingService
  include ActiveModel::Model

  attr_accessor :urls, :topics, :mentions

  validate :urls_format
  validate :topics_exist
  validate :mentions_exist

  MINISTRIES = [
    'Ministerio de Cultura',
    'Ministerio de Cultura de Buenos Aires'
  ].freeze

  MINISTERS = [
    'Ricardes',
    'Gabriela Ricardes',
    'Ministro',
    'Ministra',
    'Ministra de cultura',
    'Ministro de cultura'
  ].freeze

  def self.call(params)
    new(params).call
  end

  def call
    return failure_result(errors.full_messages) unless valid?

    external_response = call_external_service
    return failure_result('External service failed') unless external_response

    result = process_external_response(external_response)
    success_result(result)
  rescue StandardError => e
    Rails.logger.error "NewsProcessingService error: #{e.message}"
    failure_result("Processing failed: #{e.message}")
  end

  private

  def call_external_service
    ExternalAiService.call(build_request_payload)
  rescue StandardError => e
    Rails.logger.error "External service error: #{e.message}"
    nil
  end

  def process_external_response(response)
    received_count, ai_processed_count, news_items, external_errors =
      response.values_at(:received, :processed, :news, :errors)

    persistence_result = persist_news_items(news_items)

    {
      received: received_count,
      processed_by_ai: ai_processed_count,
      persisted: persistence_result[:success_count],
      news: persistence_result[:persisted_news],
      errors: normalize_errors(external_errors, persistence_result[:errors])
    }
  end

  def persist_news_items(news_items)
    NewsPersistenceService.call(news_items)
  end

  def build_request_payload
    {
      urls:,
      temas: topics,
      menciones: mentions,
      ministerios_key_words: MINISTRIES,
      ministro_key_words: MINISTERS
    }
  end

  def urls_format
    invalid_urls = urls.reject { |url| valid_url?(url) }
    return if invalid_urls.empty?

    errors.add(:urls, "Invalid URL format: #{invalid_urls.join(', ')}")
  end

  def topics_exist
    invalid_topics = topics.reject { |topic| Topic.exists?(name: topic) }
    return if invalid_topics.empty?

    errors.add(:topics, "Invalid topics: #{invalid_topics.join(', ')}")
  end

  def mentions_exist
    invalid_mentions = mentions.reject { |mention| Mention.exists?(name: mention) }
    return if invalid_mentions.empty?

    errors.add(:mentions, "Invalid mentions: #{invalid_mentions.join(', ')}")
  end

  def valid_url?(url)
    URI.parse(url).then do |uri|
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    end
  rescue URI::InvalidURIError
    false
  end

  def success_result(payload)
    ServiceResult.new(success: true, payload:)
  end

  def failure_result(error)
    ServiceResult.new(success: false, error:)
  end

  def normalize_errors(external_errors, persistence_errors)
    external_errors.map { |error|
      { url: error[:url], reason: error[:motivo] }
    } + persistence_errors
  end
end
