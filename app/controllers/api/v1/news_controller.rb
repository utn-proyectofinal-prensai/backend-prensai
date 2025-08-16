module API
  module V1
    class NewsController < API::V1::APIController
      def index
        @pagy, @news = pagy(policy_scope(New).ordered)
      end

      def batch_process
        #TODO
        head :no_content
      end
    end
  end
end
