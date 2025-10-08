# frozen_string_literal: true

FactoryBot.define do
  factory :clipping do
    name { "Clipping #{SecureRandom.hex(3)}" }
    start_date { nil }
    end_date { nil }
    topic
    creator factory: :user

    transient do
      news_count { 1 }
    end

    after(:build) do |clipping, evaluator|
      if clipping.news_ids.blank?
        clipping.start_date ||= Date.current
        clipping.end_date ||= clipping.start_date

        news_items = create_list(
          :news,
          evaluator.news_count,
          topic: clipping.topic,
          date: clipping.start_date
        )
        clipping.news_ids = news_items.map(&:id)
      else
        news_records = News.where(id: clipping.news_ids)

        clipping.topic ||= news_records.first&.topic
        clipping.start_date ||= news_records.minimum(:date) || Date.current
        clipping.end_date ||= news_records.maximum(:date) || clipping.start_date
      end

      clipping.end_date = clipping.start_date if clipping.end_date < clipping.start_date
    end
  end
end
