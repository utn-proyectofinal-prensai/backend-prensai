# frozen_string_literal: true

json.received @result[:received]
json.processed_by_ai @result[:processed_by_ai]
json.persisted @result[:persisted]

json.news @result[:news] do |news_item|
  json.partial! 'news_item', news: news_item
end

json.errors @result[:errors]
