# frozen_string_literal: true

json.id report.id
json.clipping_id report.clipping_id
json.content report.content
json.metadata report.metadata
json.manually_edited report.manually_edited?
json.created_at report.created_at.iso8601
json.updated_at report.updated_at.iso8601

if report.creator.present?
  json.creator do
    json.id report.creator.id
    json.name report.creator.name
  end
else
  json.creator nil
end

if report.reviewer.present?
  json.reviewer do
    json.id report.reviewer.id
    json.name report.reviewer.name
  end
else
  json.reviewer nil
end
