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
    success_count = 0
    persisted_news = []
    errors = []

    news_items.each do |news_data|
      result = persist_single_news(news_data)

      if result[:success]
        success_count += 1
        persisted_news << result[:news]
      else
        errors << result[:error]
      end
    end

    {
      success_count: success_count,
      persisted_news: persisted_news,
      errors: errors
    }
  end

  private

  def persist_single_news(news_data)
    news_record = NewsRecordBuilder.call(news_data)

    if news_record.persisted?
      {
        success: true,
        news: news_record # Retornamos el modelo directamente
      }
    else
      {
        success: false,
        error: "Failed to save news: #{news_record.errors.full_messages.join(', ')}"
      }
    end
  rescue StandardError => e
    Rails.logger.error "Error persisting news: #{e.message}"
    {
      success: false,
      error: "Persistence error: #{e.message}"
    }
  end
end
