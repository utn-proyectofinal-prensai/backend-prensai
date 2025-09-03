# frozen_string_literal: true

json.extract! news, :id, :title, :publication_type, :date, :support, :media, :section, :author, :interviewee, :link,
              :audience_size, :quotation, :valuation, :political_factor, :plain_text, :created_at,
              :updated_at

json.crisis news.crisis?

if news.topic.present?
  json.topic do
    json.id news.topic.id
    json.name news.topic.name
  end
else
  json.topic nil
end

json.mentions news.mentions do |mention|
  json.id mention.id
  json.name mention.name
end

json.creator do
  json.id news.creator.id
  json.name news.creator.full_name
end

json.reviewer do
  json.id news.reviewer.id
  json.name news.reviewer.full_name
end
