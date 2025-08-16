module API
  module V1
    class TopicsController < API::V1::APIController
      def index
        @topics = policy_scope(Topic).ordered
      end

      def create
        @topic = Topic.new(topic_params)
        authorize @topic
        
        if @topic.save
          render :show, status: :created
        else
          render json: { errors: @topic.errors }, status: :unprocessable_entity
        end
      end

      private

      def topic_params
        params.expect(topic: %i[name description enabled])
      end
    end
  end
end
