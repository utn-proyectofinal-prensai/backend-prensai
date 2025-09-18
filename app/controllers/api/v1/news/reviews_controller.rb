# frozen_string_literal: true

module API
  module V1
    module News
      class ReviewsController < API::V1::APIController
        before_action :set_news

        def create
          authorize @news, :review?

          result = NewsReviewCreator.call(
            news: @news,
            reviewer: current_user,
            attributes: review_attributes,
            notes: review_params[:notes]
          )

          if result.success?
            @review = result.payload
            @news.reload
            @news.association(:mentions).reset
            @news.association(:reviews).reset
            @news.association(:latest_review).reset
            render :create, status: :created
          else
            render json: { errors: format_errors(result.errors) }, status: :unprocessable_entity
          end
        end

        private

        def set_news
          @news = policy_scope(::News)
                    .includes(:topic, :creator, :mentions, reviews: :reviewer)
                    .find(params[:news_id])
        end

        def review_params
          params.expect(:review).permit(
            :title,
            :publication_type,
            :date,
            :support,
            :media,
            :section,
            :author,
            :interviewee,
            :link,
            :plain_text,
            :audience_size,
            :quotation,
            :valuation,
            :political_factor,
            :topic_id,
            :notes,
            mention_ids: []
          )
        end

        def review_attributes
          review_params.except(:notes)
        end

        def format_errors(errors)
          Array(errors).map { |message| { message: } }
        end
      end
    end
  end
end
