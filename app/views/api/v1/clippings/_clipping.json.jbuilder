# frozen_string_literal: true

json.extract! clipping, :id, :name, :period_start, :period_end, :filters, :news_ids, :created_at, :updated_at
json.news_count clipping.news_count

json.creator do
  json.id clipping.creator.id
  json.name clipping.creator.full_name
end
