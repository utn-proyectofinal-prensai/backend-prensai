# frozen_string_literal: true

module API
  module V1
    class MentionsController < API::V1::APIController
      before_action :set_mention, only: %i[update destroy]

      def index
        @mentions = policy_scope(Mention).ordered.filter_by(filtering_params)
      end

      def create
        authorize Mention, :create?
        @mention = Mention.create!(mention_params)
        render :show, status: :created
      end

      def update
        authorize @mention
        @mention.update!(mention_params)
        render :show, status: :ok
      end

      def destroy
        authorize @mention
        @mention.destroy!
        head :no_content
      end

      private

      def set_mention
        @mention = Mention.find(params[:id])
      end

      def mention_params
        params.expect(mention: %i[name enabled])
      end

      def filtering_params
        params.slice(*Mention.filter_scopes)
      end
    end
  end
end
