# frozen_string_literal: true

json.clipping_report do
  json.id @report.id
  json.clipping_id @report.clipping_id
  json.content @report.content
  json.metadata @report.metadata
  json.created_at @report.created_at.iso8601
  json.updated_at @report.updated_at.iso8601
end
