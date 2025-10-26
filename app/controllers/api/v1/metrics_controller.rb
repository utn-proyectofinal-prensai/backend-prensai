# frozen_string_literal: true

module API
  module V1
    class MetricsController < APIController
      def show
        authorize MetricSnapshot

        render json: Metrics::SnapshotFetcher.new(context: context_param).call
      end

      private

      def context_param
        params.fetch(:context, MetricSnapshot::GLOBAL_CONTEXT)
      end
    end
  end
end
