# frozen_string_literal: true

FactoryBot.define do
  factory :news_review do
    association :news
    association :reviewer, factory: :user
    changeset do
      {
        'valuation' => { 'before' => 'neutral', 'after' => 'positive' }
      }
    end
    news_snapshot do
      {
        'valuation' => 'positive'
      }
    end
    reviewed_at { Time.current }
  end
end
