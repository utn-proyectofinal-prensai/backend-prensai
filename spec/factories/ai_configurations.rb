FactoryBot.define do
  factory :ai_configuration do
    key { Faker::Lorem.unique.word }
    display_name { Faker::Lorem.sentence }
    value_type { 'string' }
    value { Faker::Lorem.sentence }
    enabled { true }
    description { Faker::Lorem.paragraph }

    trait :array_type do
      value_type { 'array' }
      value { [Faker::Lorem.word, Faker::Lorem.word] }
    end

    trait :reference_type do
      value_type { 'reference' }
      value { Faker::Number.between(from: 1, to: 100) }
      reference_type { 'Topic' }
    end

    trait :disabled do
      enabled { false }
    end

    trait :with_topic_reference do
      value_type { 'reference' }
      value { Faker::Number.between(from: 1, to: 100) }
      reference_type { 'Topic' }
    end

    trait :with_mention_reference do
      value_type { 'reference' }
      value { Faker::Number.between(from: 1, to: 100) }
      reference_type { 'Mention' }
    end
  end
end
