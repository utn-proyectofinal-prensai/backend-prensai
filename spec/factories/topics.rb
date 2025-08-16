# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    name        { Faker::Lorem.unique.word.capitalize }
    description { Faker::Lorem.paragraph }
    enabled     { true }
  end
end
