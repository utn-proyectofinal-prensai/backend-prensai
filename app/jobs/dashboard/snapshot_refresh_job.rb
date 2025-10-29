# frozen_string_literal: true

module Dashboard
  class SnapshotRefreshJob < ApplicationJob
    queue_as :default

    def perform(*args)
      context = resolve_context(args)

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

    def resolve_context(args)
      raw = args.first

      context = if raw.is_a?(Hash)
                  raw.with_indifferent_access[:context]
                else
                  raw
                end

      context.presence || DashboardSnapshot::GLOBAL_CONTEXT
    end
  end
end
