# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8) }
    username { Faker::Internet.unique.user_name }
    role     { 'user' }

    trait :admin do
      role { 'admin' }
    end
  end
end
