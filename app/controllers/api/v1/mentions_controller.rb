# frozen_string_literal: true

module API
  module V1
    class MentionsController < API::V1::APIController
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

      private

      def mention_params
        params.expect(mention: %i[name])
      end
    end
  end
end
