# frozen_string_literal: true

module API
  module V1
    class NewsController < API::V1::APIController
      before_action :set_news, only: :update

      def index
        scoped = news.filter_by(filtering_params).ordered
        @pagy, @news = pagy(scoped)
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

      def update
        authorize @news

        @news.assign_attributes(review_params)
        @news.reviewer = current_user
        @news.save!

        render :show, status: :ok
      end

      private

      def news
        policy_scope(News).includes(:topic, :mentions)
      end

      def set_news
        @news = News.find(params[:id])
      end

      def review_params
        params.expect(news: [
                        :title,
                        :publication_type,
                        :date,
                        :support,
                        :media,
                        :section,
                        :author,
                        :interviewee,
                        :audience_size,
                        :quotation,
                        :valuation,
                        :political_factor,
                        :topic_id,
                        { mention_ids: [] }
                      ])
      end

      def batch_process_params
        urls, topics, mentions = params.expect(
          urls: [],
          topics: [],
          mentions: []
        )
        { urls: urls, topics: topics, mentions: mentions }
      end

      def filtering_params
        params.permit(:topic_id, :start_date, :end_date)
      end
    end
  end
end
