# frozen_string_literal: true

module Dashboard
  class SnapshotRefreshJob < ApplicationJob
    queue_as :default

    def perform(context: DashboardSnapshot::GLOBAL_CONTEXT)
      DashboardSnapshot.create!(
        context: context,
        generated_at: Time.current,
        data: build_payload(context)
      )
    end

    private

    def build_payload(context)
      Dashboard::SnapshotBuilder.new(context: context).call
    end
  end
end
