FactoryBot.define do
  factory :ai_configuration do
    sequence(:key) { |n| "ai_config_#{n}" }
    display_name { Faker::Lorem.sentence }
    value_type { 'string' }
    value { Faker::Lorem.sentence }
    enabled { true }
    internal { false }
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

    trait :internal do
      internal { true }
    end
  end
end
