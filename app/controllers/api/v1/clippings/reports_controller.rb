# frozen_string_literal: true

module API
  module V1
    module Clippings
      class ReportsController < API::V1::APIController
        before_action :set_clipping

        def show
          authorize @clipping, :show?
          @report = @clipping.report
          return render :show, status: :ok if @report

          head :not_found
        end

        def create
          authorize @clipping, :generate_report?

          result = ::Clippings::ReportGenerator.call(@clipping)

          if result.success?
            @report = result.payload
            render :show, status: :ok
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_clipping
          @clipping = Clipping.includes(:report).find(params[:clipping_id])
        end
      end
    end
  end
end
