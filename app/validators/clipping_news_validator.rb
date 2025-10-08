# frozen_string_literal: true

class ClippingNewsValidator < ActiveModel::Validator
  def validate(record)
    return if record.news_ids.blank?

    validate_news_exist(record)
    validate_news_belong_to_topic(record)
    validate_news_within_date_range(record)
  end

  private

  def validate_news_exist(record)
    existing_ids = News.where(id: record.news_ids).pluck(:id)
    missing_ids = record.news_ids - existing_ids
    return if missing_ids.empty?

    record.errors.add(
      :news_ids,
      :non_existent,
      ids: missing_ids.join(', ')
    )
  end

  def validate_news_belong_to_topic(record)
    return unless record.topic_id.present?

    mismatched_news = News.where(id: record.news_ids).where.not(topic_id: record.topic_id)
    return unless mismatched_news.exists?

    record.errors.add(
      :news_ids,
      :topic_mismatch,
      topic_name: record.topic&.name
    )
  end

  def validate_news_within_date_range(record)
    return if record.start_date.blank? || record.end_date.blank?

    out_of_range_news = News.where(id: record.news_ids)
                            .where('date < ? OR date > ?', record.start_date, record.end_date)
    return unless out_of_range_news.exists?

    record.errors.add(
      :news_ids,
      :date_out_of_range,
      start_date: record.start_date,
      end_date: record.end_date
    )
  end
end
