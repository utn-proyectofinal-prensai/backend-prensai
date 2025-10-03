# frozen_string_literal: true

json.clippings @clippings do |clipping|
  json.partial! 'clipping', clipping: clipping
end

json.partial! 'api/v1/shared/pagination'
