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
      value { create(:topic, enabled: true).id }
      reference_type { 'Topic' }
    end

    trait :disabled do
      enabled { false }
    end
  end
end
