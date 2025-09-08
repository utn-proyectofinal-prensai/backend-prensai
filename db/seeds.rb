# frozen_string_literal: true

if Rails.env.development?
  AdminUser.create!(email: 'admin@example.com', password: 'password')

  User.create!(
    email: 'admin@prensai.com',
    password: 'admin123456',
    username: 'admin',
    first_name: 'Administrador',
    last_name: 'Sistema',
    role: 'admin'
  )

  # Crear usuario normal de prueba
  User.create!(
    email: 'user@prensai.com',
    password: 'user123456',
    username: 'user',
    first_name: 'Usuario',
    last_name: 'Normal',
    role: 'user'
  )

  topics = []
  5.times do
    topics << FactoryBot.create(:topic)
  end

  mentions = []
  5.times do
    mentions << FactoryBot.create(:mention)
  end

  news_items = []
  10.times do
    news_item = FactoryBot.create(:news, topic: topics.sample)
    selected_mentions = mentions.sample(rand(1..3))
    news_item.mentions << selected_mentions
    news_items << news_item
  end
end

Setting.create_or_find_by!(key: 'min_version', value: '0.0')

default_ai_configs = [
  {
    key: 'ministries_keywords',
    display_name: 'Palabras clave de Ministerios',
    description: 'Lista de palabras para identificar ministerios en las noticias',
    value_type: 'array',
    value: ['Ministerio de Cultura', 'Ministerio de Cultura de Buenos Aires']
  },
  {
    key: 'ministers_keywords',
    display_name: 'Palabras clave de Ministros',
    description: 'Lista de palabras para identificar ministros en las noticias',
    value_type: 'array',
    value: ['Ricardes', 'Gabriela Ricardes', 'Ministro', 'Ministra']
  },
  {
    key: 'schedule_topic',
    display_name: 'Tópico de Agenda',
    description: 'Tópico que representa la agenda/schedule de noticias',
    value_type: 'reference',
    reference_type: 'Topic'
  }
]

default_ai_configs.each do |config_data|
  AiConfiguration.find_or_create_by(key: config_data[:key]) do |config|
    config.assign_attributes(config_data)
  end
end
