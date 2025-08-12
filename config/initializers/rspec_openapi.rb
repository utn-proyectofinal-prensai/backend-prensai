# frozen_string_literal: true

return unless Rails.env.test?

require 'rspec/openapi'

# Set request `headers` - generate parameters with headers for a request
RSpec::OpenAPI.request_headers = %w[Authorization]

# Set response `headers` - generate parameters with headers for a response
RSpec::OpenAPI.response_headers = %w[Authorization]

# Support generating the docs when running specs with `parallel_tests`
RSpec::OpenAPI.path = ->(_) { "doc/openapi#{ENV.fetch('TEST_ENV_NUMBER', '')}.yaml" }
