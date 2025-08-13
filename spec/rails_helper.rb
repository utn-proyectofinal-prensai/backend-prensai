# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'

SimpleCov.start 'rails' do
  add_group 'Forms', 'app/forms'
  add_group 'Policies', 'app/policies'
  add_group 'Presenters', 'app/presenters'
  add_filter 'app/admin'
  add_filter 'config'
  add_filter 'spec'
  add_filter 'lib/tasks/code_analysis.rake'
end

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
return unless Rails.env.test?

require 'rspec/core'
require 'spec_helper'
require 'rspec/rails'
require 'rspec/retry'
require 'support/retry/message_formatter'

# Ensure test database is prepared and migrated before running the test suite
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts "Pending migrations detected. Preparing test database..."
  system('bundle exec rails db:test:prepare')
  retry
rescue ActiveRecord::NoDatabaseError
  puts "Test database does not exist. Creating it..."
  system('bundle exec rails db:test:prepare')
  retry
end
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['api.github.com', 'chrome-server:4444']
)

RSpec.configure do |config|
  config.render_views = true
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActiveJob::TestHelper
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # https://api.rubyonrails.org/v6.1.4.3/classes/ActiveSupport/Testing/TimeHelpers.html
  config.include ActiveSupport::Testing::TimeHelpers

  # Form objects specs
  config.define_derived_metadata(file_path: Regexp.new('/spec/forms/')) do |metadata|
    metadata[:type] = :form
  end
  # Only build the API Docs from files in spec/requests/api, and ignore the rest
  config.define_derived_metadata(file_path: Regexp.new('/spec/requests/')) do |metadata|
    metadata[:openapi] = false unless metadata[:file_path].match?(Regexp.new('/spec/requests/api/'))
  end

  config.include Shoulda::Matchers::ActiveModel, type: :form
  config.include Shoulda::Matchers::ActiveRecord, type: :form

  # Detects N+1 queries
  config.before { Prosopite.scan }
  config.after { Prosopite.finish }

  # Reset previous flipper instance
  config.before { Flipper.instance = nil }

  # rspec-retry gem
  # Show retry status in spec process
  config.verbose_retry = true
  # Print what reason forced the retry
  config.display_try_failure_messages = true
  # Try tests twice in the CI and once locally
  config.default_retry_count = ENV.fetch('CI', false) ? 2 : 1
  # Callback for intermittent tests
  config.intermittent_callback = proc do |ex|
    text = Retry::MessageFormatter.new(ex).to_s
    Retry::PullRequestComment.new.comment(text)
  end

  # Drop test database after suite completion to ensure idempotent test runs
  config.after(:suite) do
    puts "Cleaning up test database..."
    begin
      ActiveRecord::Base.connection_pool.disconnect!
      system('bundle exec rails db:drop RAILS_ENV=test')
      puts "Test database dropped successfully"
    rescue => e
      puts "Error dropping test database: #{e.message}"
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Flipper.configure do |config|
  config.default { Flipper.new(Flipper::Adapters::Memory.new) }
end
