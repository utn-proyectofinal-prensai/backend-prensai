# frozen_string_literal: true

class NewsPersistenceService
  include ActiveModel::Model

  attr_accessor :news_items, :creator_id

  def self.call(news_items, creator_id = nil)
    new(news_items, creator_id).call
  end

  def initialize(news_items, creator_id = nil)
    @news_items = news_items
    @creator_id = creator_id
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
    with_error_handling(news_data) do
      news_record = NewsRecordBuilder.call(news_data, creator_id)

      return success_result(news_record) if news_record.persisted?

      failure_result(news_data, news_record.errors.full_messages.join(', '))
    end
  end

  def build_error(url, reason)
    { url:, reason: }
  end

  def success_result(news_record)
    { success: true, news: news_record }
  end

  def failure_result(news_data, reason)
    { success: false, error: build_error(news_link(news_data), reason) }
  end

  def news_link(news_data)
    news_data['LINK']
  end

  def log_error(prefix, error)
    Rails.logger.error "#{prefix}: #{error.message}"
  end

  def with_error_handling(news_data)
    yield
  rescue ActiveRecord::RecordNotUnique => error
    handle_failure(news_data, error, 'Duplicate news', 'api.errors.news.duplicate_link')
  rescue ActiveRecord::RecordInvalid => error
    handle_failure(news_data, error, 'Validation error', 'api.errors.news.validation_failed')
  rescue StandardError => error
    handle_failure(news_data, error, 'Error persisting news', 'api.errors.news.internal_error')
  end

  def handle_failure(news_data, error, log_prefix, translation_key)
    log_error(log_prefix, error)
    failure_result(news_data, I18n.t(translation_key))
  end
end
