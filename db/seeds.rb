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
