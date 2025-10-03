# frozen_string_literal: true

FactoryBot.define do
  factory :clipping do
    name { "Clipping #{SecureRandom.hex(3)}" }
    period_start { Date.current }
    period_end { Date.current + 1.day }
    association :topic
    news_ids { [create(:news).id] }
    association :creator, factory: :user
  end
end
