# frozen_string_literal: true

module API
  module V1
    class ClippingsController < API::V1::APIController
      before_action :set_clipping, only: %i[show update]

      def index
        scoped = policy_scope(Clipping).ordered.filter_by(filtering_params)
        @pagy, @clippings = pagy(scoped)
      end

      def show
        authorize @clipping
      end

      def create
        @clipping = authorize Clipping.new(clipping_params.merge(creator: current_user))
        @clipping.save!
        render :show, status: :created
      end

      def update
        authorize @clipping
        @clipping.update!(clipping_params)
        render :show, status: :ok
      end

      private

      def set_clipping
        @clipping = Clipping.find(params[:id])
      end

      def clipping_params
        params.expect(
          clipping: [
            :name,
            :period_start,
            :period_end,
            :topic_id,
            { news_ids: [] }
          ]
        )
      end

      def filtering_params
        params.permit(:topic_id, :period_start, :period_end, news_ids: [])
      end
    end
  end
end
