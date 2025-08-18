# frozen_string_literal: true

module API
  module V1
    class MentionsController < API::V1::APIController
      before_action :set_mention, only: %i[update]
      def index
        @mentions = policy_scope(Mention).ordered
      end

      def create
        @mention = Mention.new(mention_params)
        authorize @mention

        if @mention.save
          render :show, status: :created
        else
          render json: { errors: @mention.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @mention
        @mention.update!(mention_params)
        render :show, status: :ok
      end

      private

      def set_mention
        @mention = Mention.find(params[:id])
      end

      def mention_params
        params.expect(mention: %i[name enabled])
      end
    end
  end
end
