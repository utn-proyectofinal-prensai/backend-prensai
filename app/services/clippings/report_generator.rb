# frozen_string_literal: true

module Clippings
  class ReportGenerator
    include ActiveModel::Model

    attr_reader :clipping

    def self.call(clipping)
      new(clipping).call
    end

    def initialize(clipping)
      @clipping = clipping
    end

    def call
      response = request_external_report

      return failure_result('External AI service is unreachable') if response.nil?
      return failure_result(response[:errors] || 'AI service processing error') unless response[:ok]

      persisted_report = persist_report(response.slice(:content, :metadata))
      success_result(persisted_report)
    rescue StandardError => error
      Rails.logger.error "Clippings::ReportGenerator error: #{error.message}"
      failure_result("Report generation failed: #{error.message}")
    end

    private

    def request_external_report
      ExternalAiService.generate_report({ metricas: metrics_payload })
    end

    def metrics_payload
      metrics = Clippings::MetricsBuilder.call(clipping)
      core_metrics_payload(metrics).merge(distribution_payload(metrics))
    end

    def period_payload(metrics)
      {
        fechaInicio: metric_start_date(metrics),
        fechaFin: metric_end_date(metrics)
      }
    end

    def metric_start_date(metrics)
      metrics.dig(:date_range, :from)&.to_s || clipping.start_date&.to_s
    end

    def metric_end_date(metrics)
      metrics.dig(:date_range, :to)&.to_s || clipping.end_date&.to_s
    end

    def valuations_payload(valuation_metrics, crisis_flag)
      valuation_metrics ||= {}

      {
        positivas: count_percentage_payload(valuation_metrics[:positive]),
        negativas: count_percentage_payload(valuation_metrics[:negative]),
        neutras: count_percentage_payload(valuation_metrics[:neutral]),
        esTemaCritico: crisis_flag
      }
    end

    def collection_payload(items)
      Array(items).map do |item|
        {
          nombre: item[:key],
          cantidad: item[:count],
          porcentaje: item[:percentage]
        }
      end
    end

    def mention_payload(items)
      Array(items).map do |item|
        {
          nombre: item[:name],
          cantidad: item[:count],
          porcentaje: item[:percentage]
        }
      end
    end

    def core_metrics_payload(metrics)
      {
        totalNoticias: metrics[:news_count],
        temaSeleccionado: clipping.topic&.name,
        fechaGeneracion: metrics[:generated_at],
        periodo: period_payload(metrics),
        valoraciones: valuations_payload(metrics[:valuation], metrics[:crisis])
      }
    end

    def distribution_payload(metrics)
      {
        soportes: collection_payload(metrics.dig(:support_stats, :items)),
        medios: collection_payload(metrics.dig(:media_stats, :items)),
        menciones: mention_payload(metrics.dig(:mention_stats, :items))
      }
    end

    def count_percentage_payload(data)
      data ||= {}
      {
        cantidad: data[:count].to_i,
        porcentaje: data[:percentage].to_f
      }
    end

    def persist_report(report_payload)
      report = clipping.report || clipping.build_report
      report.update!(content: report_payload[:content], metadata: report_payload[:metadata])
      report
    end

    def success_result(payload)
      ServiceResult.new(success: true, payload:)
    end

    def failure_result(errors)
      ServiceResult.new(success: false, errors: Array.wrap(errors))
    end
  end
end
