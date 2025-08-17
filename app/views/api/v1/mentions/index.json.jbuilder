# frozen_string_literal: true

json.mentions @mentions do |mention|
  json.partial! 'mention', mention: mention
end
