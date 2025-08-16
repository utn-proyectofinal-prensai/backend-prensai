json.extract! news, :id, :title, :publication_type, :date, :support, :media, :section, :author, :interviewee, :link, :audience_size, :quotation, :valuation, :political_factor, :management, :plain_text, :created_at, :updated_at

json.topic do
  if news.topic
    json.partial! 'api/v1/topics/topic', topic: news.topic
  else
    json.null
  end
end

json.mentions news.mentions do |mention|
  json.partial! 'api/v1/mentions/mention', mention: mention
end
