# frozen_string_literal: true

json.extract! clipping, :id, :name, :period_start, :period_end, :topic_id, :news_ids, :created_at, :updated_at
json.news_count clipping.news_count

if news.creator.present?
  json.creator do
    json.id news.creator.id
    json.name news.creator.full_name
  end
else
  json.creator nil
end
