# frozen_string_literal: true

module API
  module V1
    class TopicsController < API::V1::APIController
      before_action :set_topic, only: %i[update]
      def index
        @topics = policy_scope(Topic).ordered
      end

      def create
        authorize Topic, :create?
        @topic = Topic.create!(topic_params)
        render :show, status: :created
      end

      def update
        authorize @topic
        @topic.update!(topic_params)
        render :show, status: :ok
      end

      private

      def set_topic
        @topic = Topic.find(params[:id])
      end

      def topic_params
        params.expect(topic: %i[name description enabled])
      end
    end
  end
end
