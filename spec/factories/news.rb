# frozen_string_literal: true

FactoryBot.define do
  factory :news do
    title            { Faker::Lorem.sentence(word_count: 6) }
    publication_type { %w[article interview editorial opinion].sample }
    date             { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    support          { %w[positive negative neutral].sample }
    media            { Faker::Company.name }
    plain_text       { Faker::Lorem.paragraph(sentence_count: 5) }
    author           { Faker::Name.name }
    interviewee      { Faker::Name.name }
    link             { Faker::Internet.url }
    political_factor { %w[local regional national international].sample }
    section          { %w[politics economy society sports culture].sample }
    valuation        { %w[positive neutral negative].sample }
    quotation        { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    audience_size    { Faker::Number.between(from: 1000, to: 1_000_000) }
    topic            { association :topic }

    trait :with_mentions do
      after(:create) do |news_item|
        mentions = create_list(:mention, rand(1..3))
        news_item.mentions << mentions
      end
    end

    trait :with_creator do
      creator { association :user }
    end

    trait :with_reviewer do
      reviewer { association :user }
    end
  end
end
