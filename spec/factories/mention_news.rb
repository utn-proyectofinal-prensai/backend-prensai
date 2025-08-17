# frozen_string_literal: true

FactoryBot.define do
  factory :mention_news do
    mention { association :mention }
    news { association :news }
  end
end
