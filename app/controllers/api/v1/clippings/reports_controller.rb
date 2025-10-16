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
            @report.update!(creator: current_user)
            render :show, status: :ok
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        def update
          authorize @clipping, :update_report?

          @report = @clipping.report
          return head :not_found unless @report

          @report.assign_attributes(report_params)
          @report.reviewer = current_user
          @report.save!

          render :show, status: :ok
        end

        def export_pdf
          authorize @clipping, :show?
  
          @report = @clipping.report
          return head :not_found unless @report
          
          result = ::Clippings::ReportPdfExporter.call(@report)
          
          if result.success?
            send_data(
              result.payload[:content],
              type: 'application/pdf',
              filename: result.payload[:filename],
              disposition: 'attachment'
            )
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_clipping
          @clipping = Clipping.includes(:report).find(params[:clipping_id])
        end

        def report_params
          params.expect(
            clipping_report: [
              :content,
              metadata: {}
            ]
          )
        end
      end
    end
  end
end
