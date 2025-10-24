# frozen_string_literal: true

module API
  module V1
    class ClippingsController < API::V1::APIController
      before_action :set_clipping, only: %i[show update destroy]

      def index
        scoped = policy_scope(Clipping)
                 .filter_by(filtering_params)
                 .includes(:news, :topic, :creator, :reviewer)
                 .ordered
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
        @clipping.assign_attributes(clipping_params)
        @clipping.reviewer = current_user
        @clipping.save!
        render :show, status: :ok
      end

      def destroy
        authorize @clipping
        @clipping.destroy!
        head :no_content
      end

      private

      def set_clipping
        @clipping = Clipping.includes(:news, :topic, :report, :creator, :reviewer).find(params[:id])
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
    end
  end
end
