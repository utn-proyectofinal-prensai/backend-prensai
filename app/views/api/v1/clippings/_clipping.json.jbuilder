# frozen_string_literal: true

attributes = %i[id name start_date end_date topic_id news_ids created_at updated_at]
attributes << :metrics if local_assigns.fetch(:include_metrics, false)

json.extract! clipping, *attributes

json.creator do
  json.id clipping.creator.id
  json.name clipping.creator.full_name
end
