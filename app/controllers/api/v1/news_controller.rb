# frozen_string_literal: true

module API
  module V1
    class NewsController < API::V1::APIController
      def index
        @pagy, @news = pagy(policy_scope(News).ordered)
      end

      def batch_process
        # TODO
        head :no_content
      end
    end
  end
end
