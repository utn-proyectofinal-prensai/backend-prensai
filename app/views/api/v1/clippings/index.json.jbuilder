# frozen_string_literal: true

json.clippings @clippings do |clipping|
  json.partial! 'clipping', clipping: clipping
end
