# frozen_string_literal: true

include_news = local_assigns.fetch(:include_news, false)
include_news_ids = local_assigns.fetch(:include_news_ids, !include_news)

attributes = %i[id name start_date end_date created_at updated_at]
attributes << :metrics if local_assigns.fetch(:include_metrics, false)
attributes << :news_ids if include_news_ids

json.extract! clipping, *attributes

json.has_report clipping.report.present?

if clipping.topic.present?
  json.topic do
    json.id clipping.topic.id
    json.name clipping.topic.name
  end
else
  json.topic nil
end

if include_news
  json.news clipping.news do |news|
    json.partial! 'api/v1/news/news_item', news: news
  end
end

json.creator do
  json.id clipping.creator.id
  json.name clipping.creator.full_name
end
