# frozen_string_literal: true

module API
  module V1
    class AiConfigurationsController < API::V1::APIController
      before_action :set_ai_configuration, only: [:update]

      def index
        @ai_configurations = policy_scope(AiConfiguration).enabled.ordered
      end

      def update
        authorize @ai_configuration
        @ai_configuration.update!(ai_configuration_params)
        render :show
      end

      private

      def set_ai_configuration
        @ai_configuration = AiConfiguration.find_by!(key: params[:key])
      end

      def ai_configuration_params
        params.expect(ai_configuration: %i[value enabled])
      end
    end
  end
end
