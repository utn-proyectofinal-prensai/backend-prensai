# frozen_string_literal: true

module API
  module V1
    class ClippingsController < API::V1::APIController
      before_action :set_clipping, only: %i[show update destroy]

      def index
        scoped = policy_scope(Clipping)
                 .filter_by(filtering_params)
                 .includes(clipping_includes)
                 .ordered
        @pagy, @clippings = pagy(scoped)
      end

      def show
        authorize @clipping
      end

      def create
        @clipping = authorize Clipping.new(clipping_params.merge(creator: current_user))
        @clipping.save!
        render :create, status: :created
      end

      def update
        authorize @clipping
        @clipping.update!(clipping_params)
        render :update, status: :ok
      end

      def destroy
        authorize @clipping
        @clipping.destroy!
        head :no_content
      end

      private

      def set_clipping
        @clipping = Clipping.includes(clipping_includes).find(params[:id])
      end

      def clipping_params
        params.expect(
          clipping: [
            :name,
            :start_date,
            :end_date,
            :topic_id,
            { news_ids: [] }
          ]
        )
      end

      def filtering_params
        params.permit(:topic_id, :start_date, :end_date, news_ids: [])
      end

      def clipping_includes
        [
          :topic,
          :report,
          :creator,
          { news: %i[topic mentions creator reviewer] }
        ]
      end
    end
  end
end
