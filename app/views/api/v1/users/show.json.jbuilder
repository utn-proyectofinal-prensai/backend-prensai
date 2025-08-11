# frozen_string_literal: true

json.user do
  json.partial! 'info', user: @user
end
