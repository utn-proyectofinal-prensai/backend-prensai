# frozen_string_literal: true

json.news do
  json.partial! 'api/v1/news/news_item', news: @news, include_reviews: true
end
