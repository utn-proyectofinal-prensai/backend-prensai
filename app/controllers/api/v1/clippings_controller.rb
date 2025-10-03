# frozen_string_literal: true

module API
  module V1
    class ClippingsController < API::V1::APIController
      include HasScope

      before_action :set_clipping, only: %i[show update]

      has_scope :period_between, as: :period_range, type: :hash do |_controller, scope, value|
        start_value = value[:start] || value['start'] || value[:from] || value['from']
        end_value = value[:end] || value['end'] || value[:to] || value['to']

        start_value.present? && end_value.present? ? scope.period_between(start_value, end_value) : scope
      end

      has_scope :with_news_ids, type: :array

      has_scope :with_topic_id, as: :topic_id, type: :integer

      def index
        scoped = apply_scopes(policy_scope(Clipping).ordered)
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
    end
  end
end
