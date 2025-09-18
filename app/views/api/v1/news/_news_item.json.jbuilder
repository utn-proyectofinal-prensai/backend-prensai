# frozen_string_literal: true

include_reviews = local_assigns.fetch(:include_reviews, false)
latest_review = if include_reviews && news.association(:reviews).loaded?
                  news.reviews.first
                else
                  news.latest_review
                end

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

if news.creator.present?
  json.creator do
    json.id news.creator.id
    json.name news.creator.full_name
  end
else
  json.creator nil
end

if latest_review.present?
  json.reviewer do
    json.id latest_review.reviewer.id
    json.name latest_review.reviewer.full_name
    json.reviewed_at latest_review.reviewed_at
  end
else
  json.reviewer nil
end

if include_reviews
  json.reviews news.reviews do |review|
    json.id review.id
    json.reviewed_at review.reviewed_at
    json.notes review.notes
    json.changeset review.changeset

    json.reviewer do
      json.id review.reviewer.id
      json.name review.reviewer.full_name
    end
  end
end
