# frozen_string_literal: true

class NewsPersistenceService
  include ActiveModel::Model

  attr_accessor :news_items

  def self.call(news_items)
    new(news_items).call
  end

  def initialize(news_items)
    @news_items = news_items
  end

  def call
    successful_results, failed_results = news_items.map { |news_data| persist_single_news(news_data) }
                                                   .partition { |result| result[:success] }

    {
      success_count: successful_results.size,
      persisted_news: successful_results.pluck(:news),
      errors: failed_results.pluck(:error)
    }
  end

  private

  def persist_single_news(news_data)
    news_record = NewsRecordBuilder.call(news_data)

    if news_record.persisted?
      {
        success: true,
        news: news_record
      }
    else
      {
        success: false,
        error: build_error(news_data[:link], "Failed to save news: #{news_record.errors.full_messages.join(', ')}")
      }
    end
  rescue StandardError => e
    Rails.logger.error "Error persisting news: #{e.message}"
    {
      success: false,
      error: build_error(news_data[:link], "Persistence error: #{e.message}")
    }
  end

  def build_error(url, reason)
    { url:, reason: }
  end
end
