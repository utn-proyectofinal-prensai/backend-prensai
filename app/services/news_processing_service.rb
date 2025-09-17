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
    return failure_result(errors.full_messages) unless valid?

    handle_response(call_external_service)
  rescue StandardError => e
    Rails.logger.error "NewsProcessingService error: #{e.message}"
    failure_result("Processing failed: #{e.message}")
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

    {
      received: received_count,
      processed_by_ai: ai_processed_count,
      persisted: persistence_result[:success_count],
      news: persistence_result[:persisted_news],
      errors: normalize_errors(external_errors, persistence_result[:errors])
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

  def schedule_topic
    topic_id = AiConfiguration.get_value('schedule_topic')
    return if topic_id.blank?

    Topic.find(topic_id)&.name
  end

  def build_request_payload
    {
      urls:,
      temas: topics,
      menciones: mentions,
      ministerios_key_words: ministries_keywords,
      ministro_key_words: ministers_keywords,
      tema_agenda: schedule_topic
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
end
