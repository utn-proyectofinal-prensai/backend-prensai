# frozen_string_literal: true

json.users @users do |user|
  json.partial! 'info', user: user
end
