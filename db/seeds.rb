# frozen_string_literal: true

AdminUser.create!(email: 'admin@example.com', password: 'password') if Rails.env.development?

# Crear usuario administrador de prueba
if Rails.env.development?
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
end

Setting.create_or_find_by!(key: 'min_version', value: '0.0')

# Seeds para desarrollo
if Rails.env.development?
  puts "🌱 Creando seeds para development..."
  
  # Crear topics
  puts "📰 Creando topics..."
  topics = []
  5.times do
    topics << FactoryBot.create(:topic)
  end
  puts "✅ #{topics.count} topics creados"
  
  # Crear mentions
  puts "🏷️ Creando mentions..."
  mentions = []
  10.times do
    mentions << FactoryBot.create(:mention)
  end
  puts "✅ #{mentions.count} mentions creados"
  
  # Crear news con mentions
  puts "📰 Creando news..."
  news_items = []
  20.times do
    # Crear news con 1-3 mentions aleatorias
    news_item = FactoryBot.create(:new, topic: topics.sample)
    selected_mentions = mentions.sample(rand(1..3))
    news_item.mentions << selected_mentions
    news_items << news_item
  end
  puts "✅ #{news_items.count} news creados con mentions"
  
  puts "🎉 Seeds completados exitosamente!"
else
  puts "⚠️ Seeds solo se ejecutan en development"
end
