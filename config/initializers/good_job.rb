# frozen_string_literal: true

Rails.application.configure do
  # Don't depend on transactions
  config.good_job.enqueue_after_transaction_commit = true
  config.good_job.execution_mode = :async
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Rails.error.report(exception) }
  config.good_job.queues = '*'
  config.good_job.max_threads = 5
  config.good_job.poll_interval = 30 # seconds
  config.good_job.enable_cron = true
  config.good_job.cron_graceful_restart_period = 5.minutes
  config.good_job.cron = {
    dashboard_snapshot_refresh: {
      cron: '0 * * * *',
      class: 'Dashboard::SnapshotRefreshJob'
    }
  }
end
