# frozen_string_literal: true

module Dashboard
  class SnapshotFetcher
    DEFAULT_CONTEXT = DashboardSnapshot::GLOBAL_CONTEXT

    def initialize(context: DEFAULT_CONTEXT)
      @context = context
    end

    def call
      snapshot = DashboardSnapshot.for_context(context).ordered_by_recency.first

      {
        context: context,
        generated_at: snapshot&.generated_at,
        data: snapshot&.data || {}
      }
    end

    private

    attr_reader :context
  end
end
