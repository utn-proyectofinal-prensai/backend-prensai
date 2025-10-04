# frozen_string_literal: true

json.extract! news, :id, :title, :publication_type, :date, :support, :media, :section, :author, :interviewee, :link,
              :audience_size, :quotation, :valuation, :political_factor, :created_at, :updated_at

json.crisis news.crisis?

json.requires_manual_review news.requires_manual_review?

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

if news.creator.present?
  json.creator do
    json.id news.creator.id
    json.name news.creator.full_name
  end
else
  json.creator nil
end

if news.reviewer.present?
  json.reviewer do
    json.id news.reviewer.id
    json.name news.reviewer.full_name
  end
else
  json.reviewer nil
end
