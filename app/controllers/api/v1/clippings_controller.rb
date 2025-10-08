# frozen_string_literal: true

module API
  module V1
    class ClippingsController < API::V1::APIController
      before_action :set_clipping, only: %i[show update destroy generate_report]

      def index
        scoped = policy_scope(Clipping)
                 .filter_by(filtering_params)
                 .includes(:news)
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
        @clipping.update!(clipping_params)
        render :show, status: :ok
      end

      def destroy
        authorize @clipping
        @clipping.destroy!
        head :no_content
      end

      def generate_report
        authorize @clipping, :generate_report?

        result = Clippings::ReportGenerator.call(@clipping)

        if result.success?
          @report = result.payload
          render :generate_report, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_clipping
        @clipping = Clipping.includes(:news, :topic, :report).find(params[:id])
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
