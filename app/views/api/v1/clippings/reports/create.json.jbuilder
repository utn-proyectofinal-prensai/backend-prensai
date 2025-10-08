# frozen_string_literal: true

json.clipping_report do
  json.partial! 'api/v1/clippings/reports/report', report: @report
end
