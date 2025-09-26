# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    sequence(:name) { |n| "Topic#{n}" }
    description { Faker::Lorem.paragraph }
    enabled     { true }
    crisis      { false }
  end
end
