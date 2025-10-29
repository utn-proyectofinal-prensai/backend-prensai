# frozen_string_literal: true

module API
  module V1
    class DashboardController < APIController
      def show
        authorize DashboardSnapshot

        render json: Dashboard::SnapshotFetcher.new(context: context_param).call
      end

      private

      def context_param
        params.fetch(:context, DashboardSnapshot::GLOBAL_CONTEXT)
      end
    end
  end
end
