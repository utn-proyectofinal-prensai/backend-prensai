ENV["TZINFO_DATA_PATH"] = nil
ENV["TZINFO_DATA_SOURCE"] = "none"

begin
  require_relative "application"
  Rails.application.initialize!
rescue => e
  puts "Warning: #{e.message}"
  # Continue anyway
end