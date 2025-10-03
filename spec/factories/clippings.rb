# frozen_string_literal: true

FactoryBot.define do
  factory :clipping do
    name { "Clipping #{SecureRandom.hex(3)}" }
    period_start { Date.current }
    period_end { Date.current + 1.day }
    topic_ids { [create(:topic).id] }
    news_ids { [create(:news).id] }
    association :created_by, factory: :user
  end
end
