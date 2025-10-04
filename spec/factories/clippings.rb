# frozen_string_literal: true

FactoryBot.define do
  factory :clipping do
    name { "Clipping #{SecureRandom.hex(3)}" }
    start_date { Date.current }
    end_date { Date.current + 1.day }
    topic
    news_ids { [create(:news).id] }
    creator factory: :user
  end
end
