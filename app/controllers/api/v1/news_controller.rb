# frozen_string_literal: true

module API
  module V1
    class NewsController < API::V1::APIController
      def index
        @pagy, @news = pagy(policy_scope(News)
                               .includes(:topic, :creator, :mentions, latest_review: :reviewer)
                               .ordered)
      end

      def batch_process
        authorize News, :batch_process?

        result = NewsProcessingService.call(batch_process_params.merge(creator_id: current_user.id))

        if result.success?
          @result = result.payload
          render :batch_process, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render json: { error: 'Missing required parameters', details: e.message }, status: :bad_request
      end

      def show
        @news = policy_scope(News)
                  .includes(:topic, :creator, :mentions, reviews: :reviewer)
                  .find(params[:id])
        authorize @news
      end

      private

      def batch_process_params
        urls, topics, mentions = params.expect(
          urls: [],
          topics: [],
          mentions: []
        )
        { urls: urls, topics: topics, mentions: mentions }
      end
    end
  end
end
