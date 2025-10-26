# frozen_string_literal: true

module Metrics
  class SnapshotFetcher
    DEFAULT_CONTEXT = MetricSnapshot::GLOBAL_CONTEXT

    def initialize(context: DEFAULT_CONTEXT)
      @context = context
    end

    def call
      snapshot = MetricSnapshot.for_context(context).ordered_by_recency.first

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
