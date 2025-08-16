# frozen_string_literal: true

FactoryBot.define do
  factory :mention_new do
    mention { association :mention }
    new     { association :new }
  end
end
