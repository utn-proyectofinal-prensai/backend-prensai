# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { Faker::Internet.password(min_length: 8) }
    sequence(:username) { |n| "user#{n}" }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end

    trait :with_name do
      first_name { Faker::Name.first_name }
      last_name  { Faker::Name.last_name }
    end
  end
end
