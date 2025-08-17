# frozen_string_literal: true

FactoryBot.define do
  factory :mention do
    name { Faker::Lorem.unique.word.capitalize }

    trait :with_news do
      after(:create) do |mention|
        create_list(:news, rand(1..3), mentions: [mention])
      end
    end
  end
end
