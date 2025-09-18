# frozen_string_literal: true

json.news do
  json.partial! 'api/v1/news/news_item', news: @news, include_reviews: true
end

json.review do
  json.id @review.id
  json.reviewed_at @review.reviewed_at
  json.notes @review.notes
  json.changeset @review.changeset

  json.reviewer do
    json.id @review.reviewer.id
    json.name @review.reviewer.full_name
  end
end
