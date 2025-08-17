# frozen_string_literal: true

json.extract! news, :id, :title, :publication_type, :date, :support, :media, :section, :author, :interviewee, :link,
              :audience_size, :quotation, :valuation, :political_factor, :management, :plain_text, :created_at,
              :updated_at

json.topic do
  json.id news.topic.id
  json.name news.topic.name
end

json.mentions news.mentions do |mention|
  json.id mention.id
  json.name mention.name
end
