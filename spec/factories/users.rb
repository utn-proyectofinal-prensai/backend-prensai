# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8) }
    username { Faker::Internet.unique.user_name }
    uid      { Faker::Internet.uuid }
    role     { 'user' }

    trait :admin do
      role { 'admin' }
    end

    trait :with_name do
      first_name { Faker::Name.first_name }
      last_name  { Faker::Name.last_name }
    end
  end
end
