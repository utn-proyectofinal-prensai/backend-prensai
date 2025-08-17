json.mentions @mentions do |mention|
  json.partial! 'mention', mention: mention
end
