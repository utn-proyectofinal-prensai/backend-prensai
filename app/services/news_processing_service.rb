# frozen_string_literal: true

class NewsProcessingService
  include ActiveModel::Model

  attr_accessor :urls, :topics, :mentions, :creator_id

  validate :urls_format
  validate :topics_exist
  validate :mentions_exist

  def self.call(params)
    new(params).call
  end

  def call
    return validation_failure unless valid?
    return success_for_empty_urls if filtered_urls.empty?

    process_external_call
  rescue StandardError => error
    handle_service_failure(error)
  end

  private

  def handle_response(response)
    if response.nil?
      failure_result('External AI service is unreachable')
    elsif response[:ok]
      payload = process_external_response(response)
      success_result(payload)
    else
      failure_result(response[:errors] || 'AI service processing error')
    end
  end

  def call_external_service
    ExternalAiService.call(build_request_payload)
  rescue StandardError => e
    Rails.logger.error "External service error: #{e.message}"
    nil
  end

  def process_external_response(response)
    received_count, ai_processed_count, news_items, external_errors =
      response.values_at(:received, :processed, :news, :errors)

    persistence_result = persist_news_items(news_items) unless news_items.to_a.empty?
    persistence_result ||= default_persistence_result

    {
      received: received_count,
      processed_by_ai: ai_processed_count,
      persisted: persistence_result[:success_count],
      news: persistence_result[:persisted_news],
      errors: normalize_errors(external_errors, persistence_result[:errors]) + duplicate_errors
    }
  end

  def persist_news_items(news_items)
    NewsPersistenceService.call(news_items, creator_id)
  end

  def ministries_keywords
    AiConfiguration.get_value('ministries_keywords') || []
  end

  def ministers_keywords
    AiConfiguration.get_value('ministers_keywords') || []
  end

  def default_topic
    topic_id = AiConfiguration.get_value('default_topic')
    return if topic_id.blank?

    Topic.find(topic_id)&.name
  end

  def build_request_payload
    {
      urls: filtered_urls,
      temas: topics,
      menciones: mentions,
      ministerios_key_words: ministries_keywords,
      ministro_key_words: ministers_keywords,
      tema_default: default_topic
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

  def failure_result(errors)
    ServiceResult.new(success: false, errors:)
  end

  def normalize_errors(external_errors, persistence_errors = [])
    external_errors + persistence_errors
  end

  def filtered_urls
    @filtered_urls ||= urls.reject { |url| News.exists?(link: url) }
  end

  def duplicate_urls
    @duplicate_urls ||= urls - filtered_urls
  end

  def duplicate_errors
    duplicate_urls.map { |url| { url:, reason: I18n.t('api.errors.news.duplicate_link') } }
  end

  def empty_processing_payload
    {
      received: 0,
      processed_by_ai: 0,
      persisted: 0,
      news: [],
      errors: duplicate_errors
    }
  end

  def default_persistence_result
    {
      success_count: 0,
      persisted_news: [],
      errors: []
    }
  end

  def validation_failure
    failure_result(errors.full_messages)
  end

  def success_for_empty_urls
    success_result(empty_processing_payload)
  end

  def process_external_call
    handle_response(call_external_service)
  end

  def handle_service_failure(error)
    Rails.logger.error "NewsProcessingService error: #{error.message}"
    failure_result("Processing failed: #{error.message}")
  end
end
