# frozen_string_literal: true

FactoryBot.define do
  factory :clipping_report do
    clipping
    content { 'Reporte de clipping' }
    metadata do
      {
        'fecha_generacion' => Time.zone.now.iso8601,
        'tiempo_generacion' => '5s',
        'total_tokens' => 123
      }
    end
  end
end
