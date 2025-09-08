json.ai_configurations @ai_configurations do |config|
  json.key config[:key]
  json.display_name config[:display_name]
  json.description config[:description]
  json.value_type config[:value_type]
  json.value config[:value]
  json.enabled config[:enabled]
end
