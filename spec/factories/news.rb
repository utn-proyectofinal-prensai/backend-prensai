# frozen_string_literal: true

FactoryBot.define do
  factory :news do
    title            { Faker::Lorem.sentence(word_count: 6) }
    publication_type { %w[Declaración Agenda Entrevista Nota].sample }
    date             { Faker::Date.between(from: '2025-01-01', to: Date.current) }
    support          { %w[Grafica Digital].sample }
    media            do
      ['Clarín', 'La Nación', 'Infobae', 'Telam', 'La Gaceta', 'Pagina 12', 'El País', 'Perfil',
       'Tiempo Argentino', 'TN', 'El Cronista'].sample
    end
    plain_text       { Faker::Lorem.paragraph(sentence_count: 5) }
    author           { Faker::Name.name }
    interviewee      { Faker::Name.name }
    link             { Faker::Internet.url }
    political_factor { %w[SI NO].sample }
    section          { %w[Política Economía Sociedad Deportes Cultura].sample }
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
